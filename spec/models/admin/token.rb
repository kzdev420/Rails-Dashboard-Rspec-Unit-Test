require 'rails_helper'

RSpec.describe Admin::Token, type: :model do
  describe 'creating token' do
    it 'it has valid factory' do
      token = create(:admin_token)
    end
  end
end
