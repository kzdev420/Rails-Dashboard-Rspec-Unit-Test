require 'rails_helper'

RSpec.describe Camera, type: :model do
  describe 'creating camera' do
    it 'has valid factory' do
      camera = create(:camera)
      expect(camera).to be_valid
      expect(camera.parking_lot).to be_present
      expect(camera.name).to be_present
      expect(camera.allowed).to be_present
      expect(camera.login).to be_present
      expect(camera.password).to be_present
      expect(camera.stream).to be_a(URI::Generic)
    end
  end
end
