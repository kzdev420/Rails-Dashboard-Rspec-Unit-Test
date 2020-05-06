require 'rails_helper'

RSpec.describe Api::V1::VehiclesController, type: :request do
  let!(:user) { create(:user, :confirmed, :with_vehicles) }
  let(:vehicle) { user.active_vehicles.last }

  before do
    Manufacturer.create(name: 'Toyota')
  end

  describe 'POST #create' do
    context 'success' do
      subject do
        post '/api/v1/vehicles', headers: { Authorization: get_auth_token(user) },
          params: { vehicle: {
            plate_number: Faker::Car.number,
            vehicle_type: Faker::Car.type,
            model: Faker::Vehicle.make,
            manufacturer_id: Manufacturer.first.id
          } }
      end

      it 'should create vehicle' do
        expect { subject }.to change(user.vehicles, :count).by(1)
      end

      it_behaves_like 'response_201', :show_in_doc
    end

    context 'fail' do
      context 'duplicated vehicle' do
        subject do
          post '/api/v1/vehicles', headers: { Authorization: get_auth_token(user) },
            params: { vehicle: {
              plate_number: create(:vehicle, user: user).plate_number
            } }
        end

        it_behaves_like 'response_422', :show_in_doc
      end

      context 'vehicle without Plate Number' do
        subject do
          post '/api/v1/vehicles', headers: { Authorization: get_auth_token(user) },
            params: { vehicle: {
              plate_number: '',
              model: Faker::Vehicle.make,
              manufacturer_id: Manufacturer.first.id
            } }
        end

        it_behaves_like 'response_422', :show_in_doc
      end

      context 'vehicle without Model' do
        subject do
          post '/api/v1/vehicles', headers: { Authorization: get_auth_token(user) },
            params: { vehicle: {
              plate_number: Faker::Car.number,
              model: '',
              manufacturer_id: Manufacturer.first.id
            } }
        end

        it_behaves_like 'response_422', :show_in_doc
      end

      context 'vehicle without Manufacturer' do
        subject do
          post '/api/v1/vehicles', headers: { Authorization: get_auth_token(user) },
            params: { vehicle: {
              plate_number: Faker::Car.number,
              model: Faker::Vehicle.make,
              manufacturer_id: ''
            } }
        end

        it_behaves_like 'response_422', :show_in_doc
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'success' do
      subject do
        delete "/api/v1/vehicles/#{vehicle.id}", headers: { Authorization: get_auth_token(user) }
      end

      it_behaves_like 'response_200', :show_in_doc

      it 'should decrease user active vehicles count' do
        expect { subject }.to change(user.active_vehicles, :count).by(-1)
      end
    end

    context 'fail' do
      context 'active parking session' do
        subject do
          create(:parking_session, vehicle: vehicle)
          delete "/api/v1/vehicles/#{vehicle.id}", headers: { Authorization: get_auth_token(user) }
        end

        it_behaves_like 'response_422', :show_in_doc
      end
    end
  end

  describe 'GET #index' do
    context 'success' do
      subject do
        get "/api/v1/vehicles", headers: { Authorization: get_auth_token(user) }
      end

      it_behaves_like 'response_200', :show_in_doc

      it 'should return all vehicles' do
        subject
        expect(json.size).to eq(Vehicle.count)
      end
    end
  end

  describe 'GET #verify' do
    context 'success' do
      let(:new_vehicle) { create(:vehicle, user_id: nil) }

      subject do
        get "/api/v1/vehicles/verify", params: {
          vehicle: {
            plate_number: @plate_number
          }
        }
      end

      it 'should indicates that vehicle cannot be created', :show_in_doc do
        @plate_number = user.vehicles.first.plate_number.upcase
        subject
        expect(json['allowed']).to eq(false)
        expect(json['message'].present?).to eq(true)
      end

      it 'should indicates that vehicle is not valid', :show_in_doc do
        @plate_number = ''
        subject
        expect(json['allowed']).to eq(false)
        expect(json['message'].present?).to eq(true)
      end

      it 'should indicates that vehicle can be created because it doesn\'t exist', :show_in_doc do
        @plate_number = 'ABC123'
        subject
        expect(json['allowed']).to eq(true)
        expect(json['message'].present?).to eq(false)
      end

      it 'should indicates that vehicle can be created because it doesn\'t have any user' do
        @plate_number = new_vehicle.plate_number
        subject
        expect(json['allowed']).to eq(true)
        expect(json['message'].present?).to eq(false)
      end
    end
  end

end
