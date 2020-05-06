require 'rails_helper'

RSpec.describe Alert, type: :model do
  describe 'creating alert' do
    it 'has valid factory' do
      alert = create(:alert)
      expect(alert).to be_valid
      expect(alert.subject).to be_present
      expect(alert.user).to be_present
    end
  end
end
