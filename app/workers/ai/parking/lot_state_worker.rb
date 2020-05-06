module Ai
  module Parking
    class LotStateWorker
      include Sidekiq::Worker
      sidekiq_options queue: :state

      def perform(lot_id)
        lot = ParkingLot.find(lot_id)
        $redis_manager.ai_state.set(lot.cache_key, build_state(lot).to_json)
      end

      private

      def build_state(lot)
        {
          id: lot.id,
          outline: lot.outline,
          cameras: serialize_collection(lot.cameras, ::Api::V1::Ai::CameraSerializer),
          sessions: serialize_collection(
            lot.parking_sessions.with_attached_images.includes(:vehicle).current,
            ::Api::V1::Ai::ParkingSessionSerializer
          ),
          slots: serialize_collection(lot.parking_slots, ::Api::V1::Ai::ParkingSlotSerializer)
        }
      end

      def serialize_collection(collection, serializer)
        ActiveModel::Serializer::CollectionSerializer.new(collection, serializer: serializer)
      end
    end
  end
end
