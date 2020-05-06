require 'rails_helper'
RSpec.describe Ai::Parking::LotStateWorker, type: :worker do
  let!(:lot) { create(:parking_lot) }

  describe '#perform' do
    context 'success' do
      it 'invoked ai_state redis set with 2 arguments' do
        expect($redis_manager.ai_state).to receive(:set).with(lot.cache_key, instance_of(String))
        described_class.perform_async(lot.id)
      end

      it 'retries failed jobs' do
        expect(described_class.sidekiq_options_hash['retry']).to be_truthy
      end
    end
  end
end
