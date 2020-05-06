require 'rails_helper'

RSpec.describe Admin, type: :model do
  describe 'creating admin' do
    it 'has valid factory' do
      admin = create(:admin)
      expect(admin.valid?).to eq(true)
    end
  end
end
