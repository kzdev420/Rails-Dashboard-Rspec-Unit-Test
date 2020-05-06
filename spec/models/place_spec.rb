require 'rails_helper'

RSpec.describe Place, type: :model do
  describe 'creating place' do
    it 'has valid factory' do
      place = create(:place)

      expect(place).to be_valid
      expect(place.category).to be_present
      expect(place.distance).to be_present
      expect(place.name).to be_present
      expect(place.parking_lot).to be_present
    end
  end
end
