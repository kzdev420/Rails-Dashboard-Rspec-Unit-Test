require 'rails_helper'

RSpec.describe Ksk::Token, type: :model do
  describe 'creating ksk token' do
    it 'has valid factory' do
      token = create(:ksk_token)
      expect(token).to be_valid
      expect(token.value).to be_present
      expect(token.name).to be_present
      expect(token.kiosk).to be_present
      expect(token.last_use).to be_present
    end
  end
end
