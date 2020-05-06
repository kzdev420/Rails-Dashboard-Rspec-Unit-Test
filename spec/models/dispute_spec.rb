require 'rails_helper'

RSpec.describe Dispute, type: :model do
  describe 'creating dispute' do
    it 'has valid factory' do
      dispute = create(:dispute)
      expect(dispute).to be_valid
      expect(dispute.parking_session).to be_present
      expect(dispute.admin).to be_present
      expect(dispute.user).to be_present
      expect(dispute.status).to be_present
      expect(dispute.reason).to be_present
    end
  end
end
