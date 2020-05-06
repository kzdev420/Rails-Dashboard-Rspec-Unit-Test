require 'rails_helper'

RSpec.describe Ai::EventDispatcher, type: :service do
  let(:vehicle) { create(:vehicle) }
  let(:parking_lot) { create(:parking_lot, :with_rules) }
  let(:parking_slot) { create(:parking_slot, parking_lot: parking_lot, status: :occupied) }
  let(:parking_session) { create(:parking_session, parking_lot: parking_lot, vehicle: vehicle, parking_slot: parking_slot) }
  let(:payload) { violation_commited_payload(parking_session) }

  describe 'violation commited' do
    subject { described_class.dispatch(payload) }

    it 'creates new violation record' do
      expect { subject }.to change(Parking::Violation, :count).by(1)
    end

    it 'updates lot state in redis' do
      expect(Ai::Parking::LotStateWorker).to receive(:perform_async).with(parking_lot.id)
      subject
    end

    it 'creates new ticket record' do
      expect { subject }.to change(Parking::Ticket, :count).by(1)
    end

    it 'don\'t create violation if rule is not active' do
      parking_lot.rules.find_by(name: 'overlapping').update(status: false)
      expect { subject }.to change(Parking::Ticket, :count).by(1)
    end

    it 'saves images of violation' do
      expect { subject }.to change(Image, :count)
    end

    it 'notifies corresponding parties' do
      message = double(:message)
      allow(message).to receive(:deliver_later)
      expect(ViolationMailer).to receive(:commited).at_least(:once).and_return(message)
      subject
    end
  end
end
