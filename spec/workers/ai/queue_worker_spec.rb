require 'rails_helper'
RSpec.describe Ai::QueueWorker, type: :worker do
  let!(:lot) { create(:parking_lot) }

  describe '#perform' do
    subject { described_class.perform_async(payload) }

    context 'success' do
      let(:payload) { car_entrance_payload.merge(parking_lot_id: lot.id) }

      it 'invokes event dispatch' do
        expect(Ai::EventDispatcher).to receive(:dispatch).with(payload).and_return(true)
        subject
      end

      it { is_expected.to be_truthy }
    end

    context 'failure' do
      let(:payload) { { key: 'invalid payload' } }

      it 'raises a message error' do
        expect { subject }.to raise_error(Ai::QueueWorker::MessageNotProcessedError)
      end
    end

    context 'exception' do
      let(:payload) { 'invalid payload' }

      it 'raises standard error sub-class error' do
        expect { subject }.to raise_error(StandardError)
      end
    end
  end
end
