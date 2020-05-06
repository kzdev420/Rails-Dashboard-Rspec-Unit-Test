module ParkingLots
  module ParkingPlan
    class Create < ApplicationInteraction

      DEFAULT_NAME = 'Layout'

      interface :parking_plan_image, default: nil
      string :name, default: nil
      object :object, class: ParkingLot

      def execute
        ActiveRecord::Base.transaction do
          transactional_create!(Image, file: { data: parking_plan_image }, meta_name: name.present? ? name : DEFAULT_NAME , imageable: object)
          raise ActiveRecord::Rollback if errors.any?
        end
        self
      end
    end
  end
end
