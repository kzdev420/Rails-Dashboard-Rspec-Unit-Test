module ParkingLots
  module Outlines
    class Update < ApplicationInteraction
      array :spaces do
        hash do
          string :space_id
        end
      end

      object :object, class: ParkingLot

      # TODO: rest of the config.parking json attributes' filters can be added later

      def execute
        object.transaction(requires_new: true) do # to make sure parent transaction will be rolled back in case of exception
          slot_names_with_zones = get_slot_names_with_zones
          slot_names = slot_names_with_zones.keys

          outline_slots = object.parking_slots.where(name: slot_names)
          archived_slots = object.parking_slots - outline_slots
          new_slot_names = slot_names - outline_slots.map(&:name)

          archived_slots.each do |slot|
            transactional_update!(slot, status: :archived)
          end

          new_slot_names.each do |slot_name|
            transactional_create!(ParkingSlot, parking_lot: object, name: slot_name, zone: slot_names_with_zones[slot_name])
          end
        end
      end

      private

      def get_slot_names_with_zones
        slot_names_with_prefix = spaces.each_with_object({}) do |space, memo|
          space_id = space['space_id']
          prefix, id = ParkingSlot.name_with_prefix(space_id)
          memo[space_id] = id ? prefix : nil
        end

        grouped_zones = Parking::Zone.where(name: slot_names_with_prefix.values.compact).group_by(&:name)

        slot_names_with_prefix.transform_values! do |zone|
          next unless zone
          grouped_zones[zone] || transactional_create!(Parking::Zone, lot: object, name: zone)
        end

        slot_names_with_prefix
      end
    end
  end
end
