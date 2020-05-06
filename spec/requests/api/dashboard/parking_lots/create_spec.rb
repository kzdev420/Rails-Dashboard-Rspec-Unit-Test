require 'rails_helper'

RSpec.describe Api::Dashboard::ParkingLotsController, type: :request do
  let!(:admin) { create(:admin, role: super_admin_role) }
  let!(:town_manager) { create(:admin, role: town_manager_role) }
  let!(:parking_admin) { create(:admin, role: parking_admin_role) }

  let(:valid_params) do
    {
      email: Faker::Internet.email,
      phone: Faker::Phone.number ,
      rate: 1.5,
      name: Faker::Address.street_name,
      outline: Base64.encode64(File.read(Rails.root.join('spec/fixtures/parking_lot.parking'))),
      location: {
        country: Faker::Address.country,
        city: Faker::Address.city,
        building: Faker::Address.building_number,
        state: Faker::Address.state,
        street: Faker::Address.street_name,
        zip: Faker::Address.zip(Faker::Address.state_abbr),
        ltd: Faker::Address.latitude,
        lng: Faker::Address.longitude
      },
      parking_admin_id: parking_admin.id,
      avatar: fixture_base64_file_upload('spec/files/test.jpg'),
      status: 'active',
      town_manager_id: town_manager.id,
      rules: [
        {
          name: ::Parking::Rule.names.keys[0],
          status: 1
        }
      ]

    }
  end

  describe 'POST #create' do
    context 'success' do
      subject do
        post '/api/dashboard/parking_lots', headers: { Authorization: get_auth_token(admin) }, params: {
          parking_lot: valid_params
        }
      end

      it_behaves_like 'response_201', :show_in_doc

      it 'should create new parking lot' do
        expect { subject }.to change(ParkingLot, :count).by(1)
      end

      it 'should create new location' do
        expect { subject }.to change(Location, :count).by(1)
      end

      it 'should save parking admin and town manager' do
        subject
        parking_lot = ParkingLot.last
        expect(parking_lot.parking_admin).to eq(parking_admin)
        expect(parking_lot.town_manager).to eq(town_manager)
      end

      it 'should send mails' do
        expect(AdminMailer).to receive(:subject_created)
          .and_return( double("AdminMailer", deliver_later: true) ).once
        expect(AdminMailer).to receive(:assigned_to_parking_lot)
          .and_return( double("AdminMailer", deliver_later: true) ).twice
        subject
      end

      it 'creates rules per name' do
        expect { subject }.to change { Parking::Rule.count }.by(1)
      end

      it 'creates new setting' do
        expect { subject }.to change { Parking::Setting.count }.by(1)
      end
    end

    context 'fail: invalid params' do
      subject do
        params = valid_params
        params[:location][:building] = ''
        post '/api/dashboard/parking_lots', headers: { Authorization: get_auth_token(admin) }, params: {
          parking_lot: params
        }
      end

      it_behaves_like 'response_422', :show_in_doc

      it 'should have location errors' do
        subject
        expect(json[:errors][:building].present?).to eq(true)
      end
    end
  end
end
