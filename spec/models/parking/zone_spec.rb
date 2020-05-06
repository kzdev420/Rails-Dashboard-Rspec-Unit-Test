require 'rails_helper'

RSpec.describe Parking::Zone, type: :model do
  describe 'creating parking zone' do
    it 'has valid factory' do
      zone = create(:parking_zone)
      expect(zone).to be_valid
      expect(zone.setting).to be_present
      expect(zone.lot).to be_present
    end
  end
end
