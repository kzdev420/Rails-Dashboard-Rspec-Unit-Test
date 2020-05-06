require 'rails_helper'

RSpec.describe Ai::EventDispatcher, type: :service do
  let!(:parking_lot) { create(:parking_lot) }
  let!(:unknown_car) { create(:vehicle, plate_number: nil, user: nil) }
  let!(:known_car) { create(:vehicle) }
  let!(:parking_slot) { create(:parking_slot, parking_lot: parking_lot) }
  let(:occupied_slot) { create(:parking_slot, status: :occupied, parking_lot: parking_lot) }
  let(:timestamp) { Time.zone.now.to_i }
  describe 'car parked' do
    context 'success: known car' do
      let(:parking_session) { create(:parking_session, vehicle: known_car, parking_lot: parking_lot, parking_slot: nil ) }
      let!(:rule) { create(:parking_rule, name: :exceeding_grace_period, lot: parking_session.parking_lot) }
      let(:timestamp) { 5.minutes.ago.to_i }

      subject do
        params = car_parked_payload(parking_session, parking_slot, {}, timestamp)
        Sidekiq::Testing.fake! do
          described_class.dispatch(params)
        end
      end

      it 'should process event successfully' do
        expect(subject).to eq(true)
      end

      it 'should bind slot and session' do
        expect(parking_session.parking_slot).to eq(nil)
        expect(parking_slot.free?).to eq(true)
        subject
        expect(parking_session.reload.parking_slot_id).to eq(parking_slot.id)
        expect(parking_slot.reload.free?).to eq(false)
        expect(parking_session.reload.parked_at.to_i).to eq(timestamp)
      end

      it 'should create new notification' do
        expect { subject }.to change(User::Notification, :count).by(1)
      end

      it 'should notify user by mail' do
        expect(UserNotifier).to receive(:car_parked)
          .and_return( double("ParkingUserMailer", deliver_later: true) ).once
        subject
      end

      it 'updates lot state in redis' do
        expect(Ai::Parking::LotStateWorker).to receive(:perform_async).with(parking_lot.id)
        subject
      end

      it 'activate counter for grace period violation' do
        create(:parking_rule, name: :exceeding_grace_period, status: true, lot: parking_session.parking_lot)
        expect(Ai::Parking::GracePeriodViolationWorker).to receive(:start_counter).with(parking_session)
        subject
      end
    end

    context 'success: unknown_car' do
      let(:parking_session) { create(:parking_session, vehicle: unknown_car, parking_lot: parking_lot, parking_slot: nil) }
      let!(:rule) { create(:parking_rule, name: :exceeding_grace_period, lot: parking_session.parking_lot) }

      subject do
        params = car_parked_payload(parking_session, parking_slot)
        described_class.dispatch(params)
      end

      it 'should process event successfully' do
        expect(subject).to eq(true)
      end

      it 'shoudnt create new notification' do
        expect { subject }.to change(User::Notification, :count).by(0)
      end
    end
  end
end
