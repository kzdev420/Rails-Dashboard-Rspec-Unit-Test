require 'rails_helper'

RSpec.describe ParkingLot, type: :model do
  describe 'creating parking lot' do
    it 'has valid factory' do
      lot = create(:parking_lot)
      expect(lot.valid?).to eq(true)
      expect(lot.location.present?).to eq(true)
    end
  end
end
