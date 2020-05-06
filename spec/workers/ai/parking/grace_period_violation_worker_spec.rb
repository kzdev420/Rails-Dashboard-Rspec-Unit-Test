require 'rails_helper'
RSpec.describe Ai::Parking::GracePeriodViolationWorker, type: :worker do
  let!(:session) { create(:parking_session) }

  describe '#perform' do
    context 'success' do
      let!(:delivery) do
        double(:delivery).tap do |delivery|
          allow(delivery).to receive(:deliver_later)
        end
      end

      it 'receive session id  and parked in seconds as params' do
        create(:parking_rule, name: :exceeding_grace_period, status: true, lot: session.parking_lot)
        expect(described_class).to receive(:perform_in).with(session.parked.second,session.id).and_return(delivery)
        described_class.start_counter(session)
      end

      it 'receive session id  and parked in seconds as params' do
        create(:parking_rule, name: :exceeding_grace_period, status: false, lot: session.parking_lot)
        expect(described_class).not_to receive(:perform_in)
        described_class.start_counter(session)
      end

      it 'to not activate worker if the session is different from created' do
        create(:parking_rule, name: :exceeding_grace_period, status: true, lot: session.parking_lot)
        session.update(status: :confirmed)
        expect(described_class).not_to receive(:perform_in)
        described_class.start_counter(session)
      end

      it 'to create a violation rule when action is activated' do
        create(:parking_rule, name: :exceeding_grace_period, lot: session.parking_lot)
        session.vehicle.update(user_id: nil)
        described_class.perform_async(session.id)
        session.reload
        expect(Parking::VehicleRule.count).to eq(1)
        expect(Parking::Ticket.count).to eq(1)
        expect(Parking::Violation.count).to eq(1)
      end

      it 'to not create a violation rule when action is activated and session has an user associated to it' do
        create(:parking_rule, name: :exceeding_grace_period, lot: session.parking_lot)
        described_class.perform_async(session.id)
        session.reload
        expect(Parking::VehicleRule.count).to eq(0)
        expect(Parking::Ticket.count).to eq(0)
        expect(Parking::Violation.count).to eq(0)
      end

      it 'retries failed jobs' do
        expect(described_class.sidekiq_options_hash['retry']).to be_truthy
      end
    end
  end
end
