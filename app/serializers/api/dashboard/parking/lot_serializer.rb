module Api
  module Dashboard
    module Parking
      class LotSerializer < ::ApplicationSerializer
        attributes :id,
                   :name,
                   :parking_admin,
                   :town_manager,
                   :status,
                   :parking_plans,
                   :parking_plans,
                   :avatar,
                   :disputes_count,
                   :violations_count,
                   :email,
                   :available_cameras

        has_many :places, serializer: Api::Dashboard::PlaceSerializer
        has_one :location, serializer: LocationSerializer
        has_one :setting, serializer: SettingSerializer
        has_many :vehicle_rules, serializer: VehicleRuleSerializer do
          object.vehicle_rules.first(10)
        end

        def parking_admin
          return unless object.parking_admin
          ThinAdminSerializer.new(object.parking_admin)
        end

        def disputes_count
          object.disputes.count
        end

        def avatar
          url_for(object.avatar) if object.avatar.attached?
        end

        def parking_plans
          object.parking_plans.order("id ASC").map do |imageable|
            {
              id: imageable.id,
              url: imageable.file.attached? ? url_for(imageable.file) : '',
              name: imageable.meta_name
            }
          end
        end

        def violations_count
          object.violations.count
        end

        def town_manager
          return unless object.town_manager
          ThinAdminSerializer.new(object.town_manager)
        end

        def available_cameras
          object.cameras.count
        end

      end
    end
  end
end
