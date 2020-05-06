module ParkingLots
  module ParkingPlan
    class Update < ApplicationInteraction

      array :parking_plan_coordinates, default: []
      string :name, default: nil
      integer :parking_plan_id
      interface :parking_plan_image, default: nil
      object :object, class: ParkingLot

      def execute
        if name.present? || parking_plan_image.present?
          transactional_update!(Image.find_by(id: parking_plan_id), parking_plan_attr)
        else
          CoordinateParkingPlan.where(image_id: parking_plan_id).destroy_all
          unless parking_plan_coordinates.empty?
            parking_plan_coordinates.each do |parking_plan_coordinate|
              parking_slot_id, x, y = parking_plan_coordinate[:parking_slot_id], parking_plan_coordinate[:x], parking_plan_coordinate[:y]
              CoordinateParkingPlan.create(image_id: parking_plan_id, parking_slot_id: parking_slot_id, x: x, y: y)
            end
          end
        end
      end

      def parking_plan_attr
        attr = {}
        attr[:meta_name] = name.present? ? name : 'Layout'
        attr[:file] = { data: parking_plan_image } if parking_plan_image.present?
        attr
      end
    end
  end
end
