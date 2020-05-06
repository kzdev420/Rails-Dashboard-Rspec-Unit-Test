module Places
  class Create < ApplicationInteraction

    object :parking_lot, class: ParkingLot
    string :category
    string :name
    float :distance

    def execute
      if parking_lot.places.count >= ParkingLot::PLACES_MAX_COUNT
        errors.add(:place, :more_than_max_count, { max: ParkingLot::PLACES_MAX_COUNT })
        return self
      end
      transactional_create!(Place, inputs)
    end

  end
end
