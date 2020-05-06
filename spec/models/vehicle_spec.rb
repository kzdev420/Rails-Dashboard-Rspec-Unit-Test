require 'rails_helper'

RSpec.describe Vehicle, type: :model do
  before do
    Manufacturer.create(name: 'Toyota')
  end

  describe 'creating vehicle' do
    it 'has valid factory' do
      vehicle = create(:vehicle)
      expect(vehicle).to be_valid
      expect(vehicle.plate_number).to be_present
      expect(vehicle.color).to be_present
      expect(vehicle.model).to be_present
      expect(vehicle.vehicle_type).to be_present
      expect(vehicle.status).to be_present
      expect(vehicle.manufacturer_id).to be_present
      expect(vehicle.user).to be_present
    end
  end
end
