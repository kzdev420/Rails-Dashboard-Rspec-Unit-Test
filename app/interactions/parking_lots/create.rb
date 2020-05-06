module ParkingLots
  class Create < Base
    include CreateWithObject

    string :name
    string :email
    string :phone, default: nil
    string :status
    integer :parking_admin_id, default: nil
    integer :town_manager_id
    interface :avatar, default: nil
    string :outline, default: nil
    hash :location, strip: false
    array :places, default: []
    array :rules, default: []
    hash :setting, strip: false, default: {}

    integer :allow_save, default: 1

    validates :location, presence: true
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
        create_with_block { transactional_create!(ParkingLot, parking_lot_params) }
        create_rules
        create_location
        create_setting
        create_places
        create_slots if object.spaces
        if allow_save.zero?
          raise ActiveRecord::Rollback
        else
          notify_users
        end
      end
    end

    private

    def parking_lot_params
      super.merge(
        parking_admins: admin.nil? ? [] : [admin],
        town_managers: [manager]
      )
    end

    def create_rules
      rules.each do |rule|
        recipients = Admin.where(id: rule['recipient_ids'])
        transactional_compose!(Parking::Rules::Create, name: rule['name'], lot_id: object.id, status: rule['status'], agency_id: rule['agency_id'], admins: recipients)
      end
    end

    def create_location
      transactional_create!(Location, location_params.merge(subject: object))
    end

    def create_setting
      transactional_compose!(Parking::Settings::Create, setting_params.merge(subject_id: object.id, subject_type: object.class.name))
    end

    def notify_users
      Admin.active.full_access.find_each do |admin|
        AdminMailer.subject_created(object, admin).deliver_later
      end

      AdminMailer.assigned_to_parking_lot(object.id, object.town_manager.id).deliver_later if object.town_manager.present?
      AdminMailer.assigned_to_parking_lot(object.id, object.parking_admin.id).deliver_later if object.parking_admin.present?
    end

    def create_places
      places.each do |place|
        transactional_compose!(Places::Create, place_params(place).merge(parking_lot: object))
      end
    end

    def create_slots
      transactional_compose!(Outlines::Create, spaces: object.spaces, object: object)
    end
  end
end
