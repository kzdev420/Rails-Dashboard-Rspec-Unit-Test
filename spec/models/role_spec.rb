require 'rails_helper'

RSpec.describe Role, type: :model do
  describe 'creating role' do
    it 'has valid factory' do
      role = create(:role)
      expect(role).to be_valid
      expect(role.permissions).to be_present
    end
  end
end
