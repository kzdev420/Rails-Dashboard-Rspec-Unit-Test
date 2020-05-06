require 'rails_helper'

RSpec.describe Parking::VehicleRule, type: :model do
  describe 'creating parking vehicle rule' do
    it 'has valid factory' do
      violation = create(:parking_vehicle_rule)
      expect(violation).to be_valid
      expect(violation.lot).to be_present
      expect(violation.vehicle).to be_present
      expect(violation.color).to be_present
      expect(violation.vehicle_type).to be_present
      expect(violation.status).to be_present
    end
  end
end
