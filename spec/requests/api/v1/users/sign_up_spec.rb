require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  before do
    Manufacturer.create(name: 'Toyota')
  end

  describe 'POST #sign_up' do
    let(:vehicle_attr) do
      {
        vehicle_type: Faker::Car.type,
        plate_number: Faker::Car.number,
        model: Faker::Vehicle.make,
        color: Faker::Color.color_name,
        manufacturer_id: Manufacturer.first.id
      }
    end

    let(:valid_params) do
      {
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        email: Faker::Internet.email,
        password: Faker::Internet.password,
        phone: Faker::Phone.number,
        vehicles: [vehicle_attr]
      }
    end

    context 'success' do

      subject do
        post '/api/v1/users/sign_up', params: { user: valid_params }
      end

      it 'should create new user' do
        expect { subject }.to change(User, :count).by(1)
      end

      it 'should create new vehicles' do
        expect { subject }.to change(Vehicle, :count).by(1)
        user_vehicle = User.last.vehicles.first
        vehicle_attr.keys.each do |attr|
          user_vehicle[attr] = vehicle_attr[attr]
        end
      end

      it_behaves_like 'response_201', :show_in_doc

      it 'should send confirmation letter' do
        subject
        user = User.last
        expect(user.confirmation_token.present?).to eq(true)
        expect(user.confirmation_sent_at.present?).to eq(true)
        expect(user.confirmed?).to eq(false)
      end

      context 'vehicle created by AI' do
        let!(:vehicle) { create(:vehicle, user: nil) }

        subject do
          params = valid_params.dup
          params[:vehicles] = [vehicle.attributes]
          post '/api/v1/users/sign_up', params: { user: params }
        end

        it 'should create associated vehicles to user' do
          expect(vehicle.user_id).to eq(nil)
          subject
          vehicle.reload
          expect(vehicle.user_id).not_to eq(nil)
        end
      end
    end

    context 'fail' do
      context 'with empty params' do
        subject do
          post '/api/v1/users/sign_up'
        end

        it 'should answer with 422 status code and contains errors key', :show_in_doc do
          subject
          expect(response.code).to eq('422')
          expect(json[:errors].present?).to eq(true)
        end
      end

      context 'invalid user params' do
        subject do
          post '/api/v1/users/sign_up', params: { user: {
            email: '111',
            phone: '111',
            password: '111',
            first_name: '',
            last_name: '',
            vehicles: [{
              vehicle_type: Faker::Car.type,
              plate_number: Faker::Car.number,
              model: Faker::Vehicle.make,
              manufacturer_id: Manufacturer.first.id
            },]
          } }
        end

        it 'should answer with 422 status code and contains corresponding errors', :show_in_doc do
          subject
          expect(response.code).to eq('422')
          %w( first_name last_name phone password email).each do |param|
            expect(json[:errors][param.to_sym].present?).to eq(true)
          end
        end
      end

      context 'invalid vehicles params' do
        subject do
          params = valid_params.dup
          params[:vehicles].first[:plate_number] = ''
          params[:vehicles].first[:model] = ''
          post '/api/v1/users/sign_up', params: { user: params }
        end

        it 'shouldnt save user' do
          expect { subject }.to change(User, :count).by(0)
        end

        it 'should answer with vehicles errors', :show_in_doc do
          subject
          %i[vehicles_plate_number vehicles_model].each do |key|
            expect( json[:errors].has_key?(key) ).to eq(true)
          end
        end
      end
    end

    context 'vehicle already own by other user' do
      let!(:user) { create(:user, :confirmed, password: 'password') }
      let!(:vehicle) { create(:vehicle, user: user) }
      let(:vehicle_attr) do
        {
          vehicle_type: Faker::Car.type,
          plate_number: vehicle.plate_number,
          model: Faker::Vehicle.make,
          color: Faker::Color.color_name,
          manufacturer_id: Manufacturer.first.id
        }
      end

      let(:valid_params) do
        {
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          email: Faker::Internet.email,
          password: Faker::Internet.password,
          phone: Faker::Phone.number,
          vehicles: [vehicle_attr]
        }
      end

      subject do
        post '/api/v1/users/sign_up', params: { user: valid_params }
      end

      it 'should not allow register with a vehicle already own by other user' do
        subject
        error_message = I18n.t('active_interaction.errors.models.vehicles/create.attributes.base.already_taken_by_another_account', { plate_number: vehicle.plate_number })
        expect(json['errors']['vehicles_base'].first).to eq(error_message)
      end
    end

    context 'empty vehicles' do
      subject do
        params = valid_params.dup
        params[:vehicles].first[:plate_number] = ''
        post '/api/v1/users/sign_up', params: { user: params }
      end

      it_behaves_like 'response_422', :show_in_doc

      it 'should contains vehicle errors' do
        subject
        expect( json[:errors][:vehicles_plate_number].present? ).to eq(true)
      end
    end
  end
end
