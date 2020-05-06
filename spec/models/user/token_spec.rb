require 'rails_helper'

RSpec.describe User::Token, type: :model do
  describe 'creating token' do
    it 'it has valid factory' do
      user = create(:user)
      token = create(:user_token, user: user)
      expect(token.valid?).to eq(true)
    end

  end
end
