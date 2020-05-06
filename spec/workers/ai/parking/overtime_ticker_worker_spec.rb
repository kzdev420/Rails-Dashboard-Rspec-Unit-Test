require 'rails_helper'
RSpec.describe Ai::Parking::OvertimeTickerWorker, type: :worker do
  let!(:session) { create(:parking_session) }

  describe '#perform' do
    context 'success' do
      let!(:delivery) do
        double(:delivery).tap do |delivery|
          allow(delivery).to receive(:deliver_later)
        end
      end

      it 'sends email to an admin' do
        create(:parking_rule, name: :parking_expired, status: true, lot: session.parking_lot)
        expect(ParkingAdminMailer).to receive(:park_expired).with(instance_of(ParkingSession)).and_return(delivery)
        described_class.perform_async(session.id)
      end

      it 'retries failed jobs' do
        expect(described_class.sidekiq_options_hash['retry']).to be_truthy
      end
    end
  end
end
