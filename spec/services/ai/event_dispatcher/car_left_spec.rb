require 'rails_helper'

RSpec.describe Ai::EventDispatcher, type: :service do
  let!(:vehicle) { create(:vehicle) }
  let!(:parking_lot) { create(:parking_lot) }
  let!(:parking_slot) { create(:parking_slot, parking_lot: parking_lot, status: :occupied) }
  let!(:free_slot) { create(:parking_slot, parking_lot: parking_lot, status: :free) }

  describe 'car left' do
    context 'success: known car' do
      let!(:parking_session) { create(:parking_session, parking_lot: parking_lot, vehicle: vehicle, parking_slot: parking_slot) }

      subject do
        payload = car_left_payload(parking_session, parking_slot)
        described_class.dispatch(payload)
      end

      it 'should make parking slot available' do
        expect(parking_slot.free?).to eq(false)
        subject
        expect(parking_slot.reload.free?).to eq(true)
      end

      it 'updates lot state in redis' do
        expect(Ai::Parking::LotStateWorker).to receive(:perform_async).with(parking_lot.id)
        subject
      end
    end

    context 'fail: slot is already free' do
      let!(:parking_session) { create(:parking_session, parking_lot: parking_lot, vehicle: vehicle, parking_slot: free_slot) }

      subject do
        payload = car_left_payload(parking_session, free_slot)
        described_class.dispatch(payload)
      end

      it 'shoudnt process event' do
        expect(subject).to eq(false)
      end
    end
  end
end
