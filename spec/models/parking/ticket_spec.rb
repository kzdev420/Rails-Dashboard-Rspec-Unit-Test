require 'rails_helper'

RSpec.describe Parking::Ticket, type: :model do
  describe 'creating parking ticket' do
    it 'has valid factory' do
      ticket = build(:parking_ticket)
      expect(ticket).to be_valid
      expect(ticket.admin).to be_present
      expect(ticket.agency).to be_present
      expect(ticket.status).to be_present
    end

    it 'should create a log after update status' do
      ticket = create(:parking_ticket)
      expect { ticket.update(status: :resolved) }.to change(PaperTrail::Version, :count).by(1)
    end

    it 'should create a log after update admin_id' do
      ticket = create(:parking_ticket)
      expect { ticket.update(admin_id: nil) }.to change(PaperTrail::Version, :count).by(1)
    end

  end
end
