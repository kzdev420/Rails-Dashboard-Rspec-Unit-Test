module ParkingLots
  module ParkingPlan
    class Delete < ApplicationInteraction

      integer :id
      object :object, class: ParkingLot

      def execute
        if parking_plan = object.parking_plans.find(id)
          CoordinateParkingPlan.where(image_id: id).destroy_all
          parking_plan.destroy
        end
      end
    end
  end
end
