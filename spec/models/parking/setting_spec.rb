require 'rails_helper'

RSpec.describe Parking::Setting, type: :model do
  describe 'creating parking setting' do
    it 'has valid factory' do
      setting = create(:parking_setting)
      expect(setting).to be_valid
      expect(setting.subject).to be_present
      expect(setting.rate).to be_present
      expect(setting.overtime).to be_present
      expect(setting.parked).to be_present
      expect(setting.period).to be_present
      expect(setting.free).to be_present
    end
  end
end
