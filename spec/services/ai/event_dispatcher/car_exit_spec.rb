require 'rails_helper'

RSpec.describe Ai::EventDispatcher, type: :service do
  let!(:vehicle) { create(:vehicle) }
  let!(:parking_lot) { create(:parking_lot) }
  let!(:parking_session) { create(:parking_session, parking_lot: parking_lot, vehicle: vehicle) }

  describe 'car exit' do
    context 'success' do
      subject do
        payload = car_exit_payload(parking_session)
        described_class.dispatch(payload)
      end

      it 'should process event successfully' do
        expect(subject).to eq(true)
      end

      it 'updates lot state in redis' do
        expect(Ai::Parking::LotStateWorker).to receive(:perform_async).with(parking_lot.id)
        subject
      end
    end
  end
end
