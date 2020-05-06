require 'rails_helper'

RSpec.describe Parking::Recipient, type: :model do
  describe 'creating parking recipient' do
    it 'has valid factory' do
      recipient = create(:parking_recipient)
      expect(recipient).to be_valid
      expect(recipient.rule).to be_present
      expect(recipient.admin).to be_present
    end
  end
end
