module Agencies
  class Create < Base
    attr_reader :agency

    string :email
    string :name
    string :status, default: 'active'
    string :phone, default: nil
    integer :manager_id
    integer :town_manager_id
    array :officer_ids, default: [] do
      integer
    end
    interface :avatar, default: nil
    hash :location, strip: false

    validates :location, :email, :name, presence: true
    validate :validate_manager
    validate :validate_town_manager
    validate :validate_officers, if: -> { officer_ids&.any? }

    set_callback :execute, :after, :notify_users, if: :valid?

    def execute
      ActiveRecord::Base.transaction do
        @agency = transactional_create!(Agency, agency_params)
        transactional_create!(Location, location_params.merge(subject: agency))

        raise ActiveRecord::Rollback if errors.any?
      end
      self
    end

    private

    def agency_params
      super.merge(
        managers: [manager],
        town_managers: [town_manager],
        officers: officers
      )
    end

    def officers
      @officers.present? ? @officers : []
    end

    def notify_users
      Admin.active.full_access.find_each do |admin|
        AdminMailer.subject_created(agency, admin).deliver_later
      end

      [manager, town_manager, officers].flatten.each do |admin|
        AdminMailer.assigned_to_agency(agency.id, admin.id).deliver_later
      end

    end
  end
end
