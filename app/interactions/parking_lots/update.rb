module ParkingLots
  class Update < Base
    attr_reader :parking_lot_location

    object :object, class: ParkingLot
    string :role
    string :name
    string :status
    integer :town_manager_id
    string :email, default: nil
    string :phone, default: nil
    integer :parking_admin_id, default: nil
    interface :avatar, default: nil
    string :outline, default: nil
    hash :location, strip: false, default: {}
    array :places, default: []
    hash :setting, strip: false, default: {}

    set_callback :execute, :before, :set_previous_admins

    validate :validate_admin, if: :parking_admin_id
    validate :validate_manager, if: :town_manager_id
    validates_with Validators::Json,
                   attribute: :outline,
                   encoded: true,
                   save: true,
                   keys: ParkingLot::OUTLINE_KEYS,
                   if: :outline?

    def execute
      ParkingLot.transaction do
        transactional_update!(object, parking_lot_params)
        upsert_location
        update_setting
        update_places
        upsert_slots if outline.present?
        notify_users
      end
    end

    private

    def upsert_location
      return if location_params.blank?

      if object.location
        transactional_update!(object.location, location_params)
      else
        transactional_create!(Location, location_params.merge(subject: object))
      end
    end

    def update_setting
      return if setting.blank?
      transactional_update!(object.setting, setting_params)
    end

    def update_places
      Place.destroy(ids_removed(:places, places))

      places.each do |place|
        if place['id'].present?
          transactional_compose!(Places::Update, place_params(place).merge(object: object.places.find_by(id: place['id'])))
        else
          transactional_compose!(Places::Create, place_params(place).merge(parking_lot: object))
        end
      end
    end

    def parking_lot_params
      prms = super
      prms[:outline] = object.outline if outline.nil?
      params_allow_for_role(prms)
    end

    def params_allow_for_role(prms)
      case role.to_sym
      when :parking_admin
        # Cannot update neither parking_admin nor town_managers
      when :town_manager
        prms[:parking_admins] = [admin] if admin
      when :super_admin, :system_admin
        prms[:town_managers] = [manager] if manager
        prms[:parking_admins] = [admin] if admin
      end
      prms
    end

    def set_previous_admins
      @previous_parking_admin = object.parking_admin
      @previous_town_manager = object.town_manager
    end

    def notify_users
      Admin.active.full_access.find_each do |admin|
        AdminMailer.subject_updated(object, admin).deliver_later
      end
      object.reload
      if object.parking_admin != @previous_parking_admin && [object.parking_admin, @previous_parking_admin].all?(&:present?)
        AdminMailer.unassigned_from_parking_lot(object.id, @previous_parking_admin.id).deliver_later
        AdminMailer.assigned_to_parking_lot(object.id, object.parking_admin.id).deliver_later
      end
      if object.town_manager != @previous_town_manager && [object.town_manager, @previous_town_manager].all?(&:present?)
        AdminMailer.unassigned_from_parking_lot(object.id, @previous_town_manager.id).deliver_later
        AdminMailer.assigned_to_parking_lot(object.id, object.town_manager.id).deliver_later
      end
    end

    def upsert_slots
      transactional_compose!(Outlines::Update, spaces: object.spaces, object: object)
    end
  end
end
