require 'rails_helper'

address_attributes = %w(address1 postal_code country_code state_code city)

RSpec.describe Api::V1::UsersController, type: :request do
  before do
    Manufacturer.create(name: 'Toyota')
  end
  let(:password) { '12345678' }
  let(:phone) { Faker::Phone.number }
  let(:email) { Faker::Internet.email }
  let(:first_name) { 'new_first_name' }
  let(:billing_address) { build(:address) }
  let(:shipping_address) { build(:address) }
  let(:new_params) do
    {
      email: email,
      password: password,
      phone: phone,
      first_name: first_name
    }
  end
  let!(:user) { create(:user, :confirmed, password: password) }

  describe 'PUT #update_settings' do
    context 'success' do
      subject do
        put '/api/v1/users/update_settings', headers: { Authorization: get_auth_token(user) },
          params: { user: new_params }
      end

      it 'should update user fields' do
        subject
        user.reload
        expect(user.first_name).to eq(first_name)
        expect(user.email).to eq(email)
        expect(user.phone.tr('^0-9', '').include?(phone.tr('^0-9', ''))).to eq(true)
      end

      it_behaves_like 'response_200', :show_in_doc

      context 'Profile picture' do
        subject do
          put '/api/v1/users/update_settings', headers: { Authorization: get_auth_token(user) },
            params: @avatar_params
        end

        it 'uploads an avatar to the user account' do
          @avatar_params = {
            user: {
              avatar: fixture_base64_file_upload('spec/files/test.jpg')
            }
          }
          subject
          user.reload
          expect(user.avatar.attached?).to eq(true)
        end

        it 'removes an avatar to the user account' do
          user.update(avatar: { data: fixture_base64_file_upload('spec/files/test.jpg') })
          expect(user.avatar.attached?).to eq(true)
          @avatar_params = {
            user: {
              delete_avatar: true
            }
          }
          subject
          user.reload
          expect(user.avatar.attached?).to eq(false)
        end

      end
      1
      # Vehicles

      context "Create one vehicle", :show_in_doc do
        let!(:vehicle) { build(:vehicle) }

        subject do
          put '/api/v1/users/update_settings', headers: { Authorization: get_auth_token(user) },
            params: { user: new_params.merge(vehicles_attributes: [vehicle.attributes]) }
        end

        it 'should update user fields and add a credit card' do
          expect { subject }.to change(Vehicle, :count).by(1)
          user.reload

          vehicle_created = user.vehicles.first
          expect(vehicle_created.plate_number).to eq(vehicle.plate_number.downcase)
          expect(vehicle_created.color).to eq(vehicle.color)
          expect(vehicle_created.vehicle_type).to eq(vehicle.vehicle_type)
          expect(vehicle_created.manufacturer_id).to eq(vehicle.manufacturer_id)
          expect(vehicle_created.model).to eq(vehicle.model)
        end
      end

      context "update a deleted vehicle", :show_in_doc do
        let!(:vehicle) { create(:vehicle, user_id: user.id, status: :deleted) }

        subject do
          put '/api/v1/users/update_settings', headers: { Authorization: get_auth_token(user) },
            params: { user: new_params.merge(vehicles_attributes: [vehicle.attributes.except(:id)]) }
        end

        it 'should update user fields and add a vehicle' do
          subject
          user.reload

          vehicle_created = user.vehicles.first
          expect(vehicle_created.plate_number).to eq(vehicle.plate_number.downcase)
          expect(vehicle_created.color).to eq(vehicle.color)
          expect(vehicle_created.vehicle_type).to eq(vehicle.vehicle_type)
          expect(vehicle_created.manufacturer_id).to eq(vehicle.manufacturer_id)
          expect(vehicle_created.model).to eq(vehicle.model)
          expect(vehicle_created.status).to eq('active')
        end
      end

      context "Create a new vehicle and update a vehicle" do
        let!(:vehicle_attributes) { create(:vehicle, user_id: user.id ).attributes }

        subject do
          put '/api/v1/users/update_settings', headers: { Authorization: get_auth_token(user) },
            params: { user: new_params.merge(vehicles_attributes: [build(:vehicle).attributes, vehicle_attributes]) }
        end

        it 'should update plate number of a vehicle', :show_in_doc do
          new_plate_number = Faker::Car.number
          vehicle_attributes['plate_number'] = new_plate_number
          expect { subject }.to change(Vehicle, :count).by(1)
          user.reload
          vehicle_updated = user.vehicles.find(vehicle_attributes['id'])
          expect(vehicle_updated.plate_number).to eq(new_plate_number.downcase)
          expect(vehicle_updated.color).to eq(vehicle_attributes['color'])
          expect(vehicle_updated.vehicle_type).to eq(vehicle_attributes['vehicle_type'])
          expect(vehicle_updated.manufacturer_id).to eq(vehicle_attributes['manufacturer_id'])
          expect(vehicle_updated.model).to eq(vehicle_attributes['model'])
        end

        it 'should update all attributes of a vehicle' do
          vehicle_attributes['plate_number'] = Faker::Car.number
          vehicle_attributes['color'] = 'Black'
          vehicle_attributes['model'] = Faker::Vehicle.model
          vehicle_attributes['manufacturer_id'] = Manufacturer.first.id
          vehicle_attributes['vehicle_type'] = Faker::Vehicle.car_type

          expect { subject }.to change(Vehicle, :count).by(1)
          vehicle_updated = user.vehicles.find(vehicle_attributes['id'])
          expect(vehicle_updated.plate_number).to eq(vehicle_attributes['plate_number'].downcase)
          expect(vehicle_updated.color).to eq(vehicle_attributes['color'])
          expect(vehicle_updated.vehicle_type).to eq(vehicle_attributes['vehicle_type'])
          expect(vehicle_updated.manufacturer_id).to eq(vehicle_attributes['manufacturer_id'])
          expect(vehicle_updated.model).to eq(vehicle_attributes['model'])

          user.reload
        end
      end

      context "delete vehicles" do
        let!(:vehicle) { create(:vehicle, user_id: user.id ) }
        let!(:new_vehicle) { build(:vehicle, user_id: user.id ) }
        context "Create a new vehicle and delete an old vehicle" do

          subject do
            put '/api/v1/users/update_settings', headers: { Authorization: get_auth_token(user) },
              params: { user: new_params.merge(vehicles_attributes: [new_vehicle.attributes]) }
          end

          it 'should update user fields and vehicles' do
            subject
            user.reload
            vehicle_deleted = user.vehicles.find_by(id: vehicle.id)
            expect(vehicle_deleted.status).to eq('deleted')
          end
        end

        context "delete all vehicles" do
          let!(:vehicle2) { create(:vehicle, user_id: user.id ) }
          let!(:vehicle3) { create(:vehicle, user_id: user.id ) }

          subject do
            put '/api/v1/users/update_settings', headers: { Authorization: get_auth_token(user), 'Content-Type': 'application/json' },
              params: { user: new_params.merge(vehicles_attributes: []) }.to_json
          end

          it 'should update user fields and vehicle' do
            subject
            user.reload
            expect(user.active_vehicles.size).to eq(0)
            user.vehicles.each do |vehicle|
              expect(vehicle.status).to eq('deleted')
            end
          end
        end

      end

      #
      # Credit Cards

      context "Create one credit card", :show_in_doc do
        let!(:credit_card) { build(:credit_card) }

        subject do
          put '/api/v1/users/update_settings', headers: { Authorization: get_auth_token(user) },
            params: { user: new_params.merge(credit_cards_attributes: [credit_card.attributes]) }
        end

        it 'should update user fields and add a credit card' do
          expect { subject }.to change(CreditCard, :count).by(1)
          user.reload

          credit_card_created = user.credit_cards.first
          expect(credit_card_created.number).to eq(credit_card.number)
          expect(credit_card_created.holder_name).to eq(credit_card.holder_name)
          expect(credit_card_created.expiration_year).to eq(credit_card.expiration_year)
          expect(credit_card_created.expiration_month).to eq(credit_card.expiration_month)
          expect(user.default_credit_card_id).to eq(credit_card_created.id)
        end
      end

      context 'set default credit card' do
        let!(:new_credit_card) { build(:credit_card) }
        let!(:credit_card1) { create(:credit_card, user_id: user.id ) }
        let!(:credit_card2) { create(:credit_card, user_id: user.id ) }

        subject do
          put '/api/v1/users/update_settings', headers: { Authorization: get_auth_token(user), 'Content-Type': 'application/json' },
            params: { user: new_params.merge(credit_cards_attributes: @credit_card_attributes) }.to_json
        end

        it 'should update user default credit card fields' do
          @credit_card_attributes = [
            credit_card1,
            credit_card2,
            new_credit_card.attributes.merge(
              default: 1
            )
          ]
          expect(user.default_credit_card_id).to eq(nil)
          subject
          user.reload
          expect(user.credit_cards.size).to eq(3)
          expect(user.default_credit_card_id).not_to eq(nil)
          expect(CreditCard.find(user.default_credit_card_id).number).to eq(new_credit_card[:number])
        end

        it 'should update user default credit card fields even if it\'s not set because it\'s the only one' do
          user.update(default_credit_card_id: user.credit_cards.first.id)

          @credit_card_attributes = [
            new_credit_card.attributes.merge(
              default: 0
            )
          ]
          subject
          user.reload
          expect(user.credit_cards.size).to eq(1)
          expect(user.default_credit_card_id).not_to eq(nil)
          expect(CreditCard.find(user.default_credit_card_id).number).to eq(new_credit_card[:number])
        end
      end

      context "Create a new credit card and not update a credit card" do
        let!(:credit_card_attributes) do
          attributes = create(:credit_card, user_id: user.id ).attributes
          attributes['number'] = "#{CreditCard::ENCRIPTED_SYMBOL * attributes['number'][1..-4].size}#{attributes['number'][-4..-1]}"
          attributes
        end

        subject do
          put '/api/v1/users/update_settings', headers: { Authorization: get_auth_token(user) },
            params: { user: new_params.merge(credit_cards_attributes: [build(:credit_card).attributes, credit_card_attributes]) }
        end

        it 'should not update any attributes of a credit card' do
          credit_card_attributes['number'] = '5105105105105100'
          credit_card_attributes['holder_name'] = Faker::Name.name
          expect { subject }.to change(CreditCard, :count).by(1)
          user.reload
          credit_card_updated = user.credit_cards.find(credit_card_attributes['id'])
          expect(credit_card_updated.number).not_to eq(credit_card_attributes['number'])
          expect(credit_card_updated.holder_name).not_to eq(credit_card_attributes['holder_name'])
        end
      end

      context "delete credit card" do
        let!(:credit_card) { create(:credit_card, user_id: user.id ) }
        context "Create a new credit card and delete an old credit card" do

          subject do
            put '/api/v1/users/update_settings', headers: { Authorization: get_auth_token(user) },
              params: { user: new_params.merge(credit_cards_attributes: [build(:credit_card).attributes]) }
          end

          it 'should update user fields and credit card' do
            subject
            user.reload
            credit_card_deleted = user.credit_cards.find_by(id: credit_card.id)
            credit_card_created = user.credit_cards.first
            expect(credit_card_deleted).to eq(nil)
            expect(user.default_credit_card_id).to eq(credit_card_created.id)
          end
        end
        context "delete all credit cards" do
          let!(:credit_card2) { create(:credit_card, user_id: user.id ) }
          let!(:credit_card3) { create(:credit_card, user_id: user.id ) }

          subject do
            put '/api/v1/users/update_settings', headers: { Authorization: get_auth_token(user), 'Content-Type': 'application/json' },
              params: { user: new_params.merge(credit_cards_attributes: []) }.to_json
          end

          it 'should update user fields and credit card' do
            subject
            user.reload
            expect(user.credit_cards.size).to eq(0)
          end
        end

      end

      #
      ## Without Password
      context 'Without Password' do
        let(:new_params) do
          {
            email: email,
            phone: phone,
            first_name: first_name
          }
        end

        subject do
          put '/api/v1/users/update_settings', headers: { Authorization: get_auth_token(user) },
            params: { user: new_params }
        end

        it 'should not need password on the params to update user fields' do
          subject
          user.reload
          expect(user.first_name).to eq(first_name)
          expect(user.email).to eq(email)
          expect(user.phone.tr('^0-9', '').include?(phone.tr('^0-9', ''))).to eq(true)
        end
      end

      context 'should update birthday' do
        let(:new_params) do
          {
            birthday: 20.years.ago,
          }
        end

        subject do
          put '/api/v1/users/update_settings', headers: { Authorization: get_auth_token(user) },
            params: { user: new_params }
        end

        it 'should not need password on the params to update user fields' do
          subject
          user.reload
          expect(user.birthday).to eq(20.years.ago.to_date)
        end
      end

      #
      # Addresses

      context 'with addresses' do
        context 'with billing address' do
          subject do
            put '/api/v1/users/update_settings', headers: { Authorization: get_auth_token(user) },
              params: { user: new_params.merge(billing_address: billing_address.attributes ) }
          end
          it 'should update user fields' do
            subject
            user.reload

            address_attributes.each do |key|
              expect(user.billing_address[key]).to eq(billing_address[key])
            end
            expect(user.shipping_address).to eq(nil)

          end
        end

        context 'with shipping address' do
          context 'equal to billing address', :show_in_doc  do
            subject do
              put '/api/v1/users/update_settings', headers: { Authorization: get_auth_token(user) },
                params: { user: new_params.merge(billing_address: billing_address.attributes, shipping_address: { shipping_address_same_as_billing: true } ) }
            end
            it 'should update user fields' do
              subject
              user.reload

              address_attributes.each do |key|
                expect(user.shipping_address[key].downcase).to eq(billing_address[key].downcase)
                expect(user.billing_address[key].downcase).to eq(billing_address[key].downcase)
              end
            end
          end

          context 'different to billing address' do
            subject do
              put '/api/v1/users/update_settings', headers: { Authorization: get_auth_token(user) },
                params: { user: new_params.merge(shipping_address: shipping_address.attributes) }
            end
            it 'should update user fields' do
              subject
              user.reload

              address_attributes.each do |key|
                expect(user.shipping_address[key]).to eq(shipping_address[key])
              end
              expect(user.billing_address).to eq(nil)
            end
          end
        end

        context 'with billing and shipping address' do
          subject do
            put '/api/v1/users/update_settings', headers: { Authorization: get_auth_token(user) },
            params: { user: new_params.merge(shipping_address: shipping_address.attributes, billing_address: billing_address.attributes) }
          end
          it 'should update user fields', :show_in_doc do
            subject
            user.reload

            address_attributes.each do |key|
              expect(user.billing_address[key]).to eq(billing_address[key])
              expect(user.shipping_address[key]).to eq(shipping_address[key])
            end
          end
        end

      end

    end
  end

  context 'fail' do
    context 'invalid password' do
      subject do
        put '/api/v1/users/update_settings', headers: { Authorization: get_auth_token(user) },
          params: { user: new_params.merge(password: 'invalid_password') }
      end

      it_behaves_like 'response_422'

      it 'contains password error' do
        subject
        expect(json[:errors][:password].present?).to eq(true)
      end
    end

    context 'taken email' do
      subject do
        put '/api/v1/users/update_settings', headers: { Authorization: get_auth_token(user) },
          params: { user: new_params.merge(email: create(:user).email) }
      end

      it_behaves_like 'response_422', :show_in_doc

      it 'contains email error' do
        subject
        expect(json[:errors][:base].present?).to eq(true)
      end
    end

    context 'invalid credit card' do
      let!(:credit_card_attributes) do
        attributes = build(:credit_card, user_id: user.id ).attributes
        attributes['number'] = "#{CreditCard::ENCRIPTED_SYMBOL * attributes['number'][1..-4].size}#{attributes['number'][-4..-1]}"
        attributes
      end
      subject do
        put '/api/v1/users/update_settings', headers: { Authorization: get_auth_token(user) },
          params: { user: new_params.merge(credit_cards_attributes: [credit_card_attributes]) }
      end

      after do
        expect(json[:errors][:base].present?).to eq(true)
      end

      it 'expired credit card' do
        credit_card_attributes['expiration_month'] = 1
        credit_card_attributes['expiration_year'] = Time.zone.today.year % 100
        subject
      end
      it 'invalid number', :show_in_doc  do
        credit_card_attributes['number'] = '4'
        subject
      end
      it 'invalid expiration year' do
        credit_card_attributes['expiration_year'] = 10
        subject
      end
      it 'invalid expiration month' do
        credit_card_attributes['expiration_month'] = 0
        subject
      end

    end
  end
end
