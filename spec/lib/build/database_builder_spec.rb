require 'rails_helper'

destroy_models = [
  Agency,
  ParkingSlot,
  ParkingLot,
  ParkingSession,
  Vehicle,
  Camera,
  Admin,
  Role
]

describe Build::DatabaseBuilder do
  before(:all) do
    create(:user, :confirmed)
  end

  subject { Build::DatabaseBuilder.run }

  describe 'existing records deletion' do
    after { subject }

    it "destroys existing #{destroy_models.map(&:name).join(', ')}" do
      destroy_models.each do |entity|
        expect(entity).to receive(:destroy_all).and_call_original
      end
    end
  end

  describe 'filling database with new records' do
    it 'creates models' do
      Role.destroy_all
      expect { subject }.to change(Agency, :count).by(1)
      .and change(Role, :count).by(6)
      .and change(Admin, :count).by(6)
      .and change(ParkingLot, :count).by(30)
      .and change(ParkingSlot.occupied, :count).by(25)
      .and change(Location, :count).by(31)
      .and change(Parking::Rule, :count).by(Parking::Rule.names.size * 30)
      .and change(ParkingSlot, :count).by(1500)
      .and change(Parking::Setting, :count).by(30)
      .and change(Camera, :count).by(1)
      .and change(Kiosk, :count).by(1)
      .and change(Ksk::Token, :count).by(1)
      .and change(Vehicle, :count).by(5)
      .and change(ParkingSession, :count).by(55)
      .and change(Alert, :count).by(1)
    end
  end
end
