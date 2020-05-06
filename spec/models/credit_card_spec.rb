require 'rails_helper'

RSpec.describe CreditCard, type: :model do
  describe 'creating credit_card' do
    it 'has valid factory' do
      user = create(:user)
      credit_card = create(:credit_card, user_id: user.id)
      expect(credit_card).to be_valid
      expect(credit_card.number).to be_present
      expect(credit_card.holder_name).to be_present
      expect(credit_card.expiration_year).to be_present
      expect(credit_card.expiration_month).to be_present
    end
  end
end
