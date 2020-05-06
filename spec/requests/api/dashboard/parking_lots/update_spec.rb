require 'rails_helper'

RSpec.describe Api::Dashboard::ParkingLotsController, type: :request do
  let!(:admin) { create(:admin, role: super_admin_role) }
  let!(:parking_lot) do
    lot = create(:parking_lot)
    lot.admins = [
      create(:admin, role: parking_admin_role),
      create(:admin, role: town_manager_role)
    ]
    lot
  end
  let!(:parking_admin) { create(:admin, role: parking_admin_role) }
  let!(:town_manager) { create(:admin, role: town_manager_role) }

  let(:valid_params) do
    {
      email: Faker::Internet.email,
      phone: Faker::Phone.number ,
      rate: 1.5,
      name: Faker::Address.street_name,
      parking_admin_id: parking_admin&.id,
      town_manager_id: town_manager.id,
      outline: Base64.encode64(File.read(Rails.root.join('spec/fixtures/parking_lot.parking'))),
      status: 'active',
      setting: {
        rate: 20.0,
        parked: 10.minutes.to_i,
        overtime: 15.minutes.to_i,
        period: 12.minutes.to_i
      }
    }
  end
  let(:current_role) { :admin }

  describe 'PUT #update' do
    context 'success' do
      subject do
        put "/api/dashboard/parking_lots/#{parking_lot.id}", headers: { Authorization: get_auth_token(send(current_role)) }, params: {
          parking_lot: valid_params
        }
      end

      it_behaves_like 'response_200', :show_in_doc

      it 'should save parking admin and town_manager' do
        subject
        parking_lot.reload
        expect(parking_lot.parking_admin).to eq(parking_admin)
        expect(parking_lot.town_manager).to eq(town_manager)
      end

      it 'updates setting' do
        subject
        parking_lot.reload
        expect(parking_lot.setting).to have_attributes(
                                                        rate: 20.0,
                                                        parked: 10.minutes.to_i,
                                                        overtime: 15.minutes.to_i,
                                                        period: 12.minutes.to_i
                                                      )
      end

      it 'should send mails' do
        expect(AdminMailer).to receive(:subject_updated)
          .and_return( double("AdminMailer", deliver_later: true) ).once
        expect(AdminMailer).to receive(:unassigned_from_parking_lot)
          .and_return( double("AdminMailer", deliver_later: true) ).twice
        expect(AdminMailer).to receive(:assigned_to_parking_lot)
          .and_return( double("AdminMailer", deliver_later: true) ).twice
        subject
      end

      it 'should add several nearby places', only: true do
        place = build(:place)
        valid_params[:places] = [place.attributes]
        expect { subject }.to change(Place, :count).by(1)
        expect(json[:places].count).to eq(1)
        expect(json[:places].first[:name]).to eq(place.name)
      end

      context 'when old parking admin is nil' do
        let!(:parking_lot) { create(:parking_lot, admins: [create(:admin, role: town_manager_role)]) }

        it_behaves_like 'response_200', :show_in_doc

        it 'should save parking admin and town_manager' do
          subject
          parking_lot.reload
          expect(parking_lot.parking_admin).to eq(parking_admin)
          expect(parking_lot.town_manager).to eq(town_manager)
        end

        it 'should send mails only for town_manager' do
          expect(AdminMailer).to receive(:unassigned_from_parking_lot)
            .and_return( double("AdminMailer", deliver_later: true) ).once
          expect(AdminMailer).to receive(:assigned_to_parking_lot)
            .and_return( double("AdminMailer", deliver_later: true) ).once
          subject
        end
      end

      context "current user is a parking admin" do
        let(:current_role) { :parking_admin }
        let!(:new_parking_admin) { create(:admin, role: parking_admin_role) }
        let(:valid_params) do
          {
            email: Faker::Internet.email,
            phone: Faker::Phone.number ,
            rate: 1.5,
            name: Faker::Address.street_name,
            parking_admin_id: new_parking_admin&.id,
            outline: Base64.encode64(File.read(Rails.root.join('spec/fixtures/parking_lot.parking'))),
            status: 'active',
            setting: {
              rate: 20.0,
              parked: 10.minutes.to_i,
              overtime: 15.minutes.to_i,
              period: 12.minutes.to_i
            }
          }
        end
        it 'should not let parking admin update parking_admin attribute' do
          parking_lot.update(admins: [parking_admin, town_manager])
          subject
          parking_lot.reload
          expect(parking_lot.parking_admin.id).to eq(parking_admin.id)
        end
      end

      context "current user is a town manager" do
        let(:current_role) { :town_manager }
        let!(:new_town_manager) { create(:admin, role: town_manager_role) }
        let!(:new_parking_admin) { create(:admin, role: parking_admin_role) }
        let(:valid_params) do
          {
            email: Faker::Internet.email,
            phone: Faker::Phone.number ,
            rate: 1.5,
            name: Faker::Address.street_name,
            parking_admin_id: new_parking_admin&.id,
            town_manager_id: new_town_manager&.id,
            outline: Base64.encode64(File.read(Rails.root.join('spec/fixtures/parking_lot.parking'))),
            status: 'active',
            setting: {
              rate: 20.0,
              parked: 10.minutes.to_i,
              overtime: 15.minutes.to_i,
              period: 12.minutes.to_i
            }
          }
        end
        it 'should not be able to update town_manager attribute but it can update parking_admin attribute' do
          parking_lot.update(admins: [town_manager, parking_admin])
          subject
          parking_lot.reload
          expect(parking_lot.town_manager.id).to eq(town_manager.id)
          expect(parking_lot.parking_admin.id).to eq(new_parking_admin.id)
        end
      end
    end
  end
end
