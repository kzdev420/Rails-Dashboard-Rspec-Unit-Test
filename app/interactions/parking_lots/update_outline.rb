module ParkingLots
  class UpdateOutline < Base
    attr_reader :parking_lot_location

    object :object, class: ParkingLot

    string :outline, default: nil

    validates_with Validators::Json,
                   attribute: :outline,
                   encoded: true,
                   save: true,
                   keys: ParkingLot::OUTLINE_KEYS,
                   if: :outline?

    def execute
      ParkingLot.transaction do
        transactional_update!(object, parking_lot_params)
        upsert_slots if outline.present?
      end
    end

    private

    def parking_lot_params
      {
        outline: outline.nil? ? object.outline : inputs[:outline]
      }
    end

    def upsert_slots
      transactional_compose!(Outlines::Update, spaces: object.spaces, object: object)
    end
  end
end
