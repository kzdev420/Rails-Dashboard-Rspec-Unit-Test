require 'rails_helper'

RSpec.describe Payment, type: :model do
  describe 'creating payment' do
    it 'has valid factory' do
      payment = create(:payment, :success)
      expect(payment).to be_valid
      expect(payment).to be_success
      expect(payment.amount).to be_present
      expect(payment.parking_session).to be_present
    end
  end
end
