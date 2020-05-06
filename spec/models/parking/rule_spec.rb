require 'rails_helper'

RSpec.describe Parking::Rule, type: :model do
  describe 'creating parking rule' do
    it 'has valid factory' do
      rule = create(:parking_rule)
      expect(rule).to be_valid
      expect(rule.lot).to be_present
      expect(rule.agency).to be_present
    end
  end
end
