module Api
  module V1
    module Ksk
      class ParkingLotSerializer < ::ParkingLotSerializer
        attributes  :id,
                    :name,
                    :address,
                    :available,
                    :capacity,
                    :rate,
                    :free,
                    :email,
                    :period,
                    :phone,
                    :lng,
                    :ltd

        attr_reader :with_slots

        attribute :slots, if: :with_slots
        attribute :outline, if: :with_slots

        def initialize(record, with_slots: false, **options)
          @with_slots = with_slots
          super
        end

        def slots
          lot_slots.sort_by { |a| a.free? ? 1 : 0 }.map do |slot|
            {
              id: slot.name,
              available: slot.free?
            }
          end
        end

        def outline
          data = object.outline&.with_indifferent_access || {}
          spaces = data.delete('spaces')
          spaces.each { |space| space['slot_id'] = space.delete('space_id') } if spaces
          data['slots'] = spaces || []
          data
        end

        def period
          ::ParkingLot::PERIOD_NORMALIZER
        end

      end
    end
  end
end
