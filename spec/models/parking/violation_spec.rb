require 'rails_helper'

RSpec.describe Parking::Violation, type: :model do
  describe 'creating parking violation' do
    it 'has valid factory' do
      violation = create(:parking_violation)
      expect(violation).to be_valid
      expect(violation.rule).to be_present
      expect(violation.session).to be_present
      expect(violation.fixed_at).to be_present
      expect(violation.description).to be_present
    end
  end
end
