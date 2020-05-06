module Parking
  module VehicleRules
    class Check < ApplicationInteraction
      object :vehicle, class: 'Vehicle'

      def execute
        return if Rails.env.production? # Avoid uncessary notification in production while it gets clean
        vehicle_rule = VehicleRule.find_by(vehicle_id: vehicle.id, status: :active)
        notify_admin(vehicle_rule) if vehicle_rule.present?
      end

      private

      def notify_admin(vehicle_rule)
        ParkingAdminMailer.voi_notification(vehicle_rule.id, vehicle.id).deliver_later
      end
    end
  end
end
