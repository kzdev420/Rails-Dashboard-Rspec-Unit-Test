module Agencies
  class Update < Base
    attr_reader :agency_location

    object :agency, class: Agency
    string :email, default: nil
    string :name, default: nil
    string :status, default: 'active'
    string :phone, default: nil
    integer :manager_id, default: nil
    integer :town_manager_id, default: nil
    array :officer_ids, default: [] do
      integer
    end
    interface :avatar, default: nil
    hash :location, strip: false, default: {}

    validate :validate_manager, if: :manager_id
    validate :validate_town_manager, if: :town_manager_id
    validate :validate_officers, if: -> { officer_ids&.any? }

    set_callback :execute, :before, :set_previous_admins
    set_callback :execute, :after, :notify_users, if: :valid?

    def execute
      ActiveRecord::Base.transaction do
        transactional_update!(agency, agency_params)
        transactional_update!(agency.location, location_params)
        raise ActiveRecord::Rollback if errors.any?
      end
      self
    end

    private

    def notify_users
      agency.reload

      Admin.active.full_access.find_each do |admin|
        AdminMailer.subject_updated(agency, admin).deliver_later
      end

      new_manager = agency.manager
      new_town_manager = agency.town_manager
      new_officers = agency.officers

      if @previous_manager != new_manager && [@previous_manager, new_manager].all?(&:present?)
        AdminMailer.assigned_to_agency(agency.id, new_manager.id).deliver_later
        AdminMailer.unassigned_from_agency(agency.id, @previous_manager.id).deliver_later
      end

      if @previous_town_manager != new_town_manager && [@previous_town_manager, new_town_manager].all?(&:present?)
        AdminMailer.assigned_to_agency(agency.id, new_town_manager.id).deliver_later
        AdminMailer.unassigned_from_agency(agency.id, @previous_town_manager.id).deliver_later
      end

      if Set.new(@previous_officers) != Set.new(new_officers)
        (@previous_officers - new_officers).each do |admin|
          remove_from_agency(agency, admin)
          AdminMailer.unassigned_from_agency(agency.id, admin.id).deliver_later
        end
        (new_officers - @previous_officers).each do |admin|
          AdminMailer.assigned_to_agency(agency.id, admin.id).deliver_later
        end
      end
    end

    def set_previous_admins
      @previous_officers = agency.officers.to_a
      @previous_manager = agency.manager
      @previous_town_manager = agency.town_manager
    end

    def agency_params
      prms = super
      prms[:managers] = [manager] if manager
      prms[:town_managers] = [town_manager] if town_manager
      prms[:officers] = officers&.any? ? officers : []
      prms
    end

    def remove_from_agency(agency, admin)
      ::Parking::Ticket.where(admin_id: admin.id, agency_id: agency.id).update_all(admin_id: nil)
    end
  end
end
