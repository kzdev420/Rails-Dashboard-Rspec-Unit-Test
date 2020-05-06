require 'rails_helper'

RSpec.describe Api::Dashboard::ParkingPlansController, type: :request do
  let!(:admin) { create(:admin, role: super_admin_role) }
  let!(:town_manager) { create(:admin, role: town_manager_role) }
  let!(:parking_admin) { create(:admin, role: parking_admin_role) }

  let!(:parking_lot) do
    lot = create(:parking_lot)
    lot.admins = [
      create(:admin, role: parking_admin_role),
      create(:admin, role: town_manager_role)
    ]
    lot
  end
  let!(:slots) { create_list(:parking_slot, 4, parking_lot: parking_lot) }

  let!(:plans) { create_list(:parking_plans, 2, imageable: parking_lot) }
  let(:parking_plan_id) { parking_lot.parking_plans.first.id }

  let(:new_parking_plan_name) { 'New Plan name' }

  let(:valid_params) do
    {
      parking_plan_image: fixture_base64_file_upload('spec/files/test.jpg'),
      name: parking_plan_name
    }
  end

  describe 'PUT #update' do
    context 'success' do

      context "empty params" do
        subject do
          put "/api/dashboard/parking_lots/#{parking_lot.id}/parking_plans/#{parking_plan_id}", headers: { Authorization: get_auth_token(admin) }
        end
        it_behaves_like 'response_200', :show_in_doc
      end

      context "new coordinates" do
        let!(:coordinates) { create_list(:coordinate_parking_plan, 3, parking_slot_id: parking_lot.parking_slots.first.id, image_id: parking_plan_id  ) }
        let!(:valid_params) do
          {
            parking_plan_coordinates: [build(:coordinate_parking_plan, parking_slot_id: parking_lot.parking_slots.first.id).attributes]
          }
        end
        subject do
          put "/api/dashboard/parking_lots/#{parking_lot.id}/parking_plans/#{parking_plan_id}", headers: { Authorization: get_auth_token(admin) }, params: valid_params
        end

        it 'save a new coordinate' do
          # It should delete the previous coordinates and add just the new one
          expect { subject }.to change(CoordinateParkingPlan, :count).by(-2)
        end
      end

      context "new image and name" do
        let(:valid_params) do
          {
            parking_plan_image: fixture_base64_file_upload('spec/files/test.jpg'),
            name: new_parking_plan_name
          }
        end

        subject do
          put "/api/dashboard/parking_lots/#{parking_lot.id}/parking_plans/#{parking_plan_id}", headers: { Authorization: get_auth_token(admin) }, params: valid_params
        end

        it_behaves_like 'response_200', :show_in_doc

        it 'should change the name and use a new image' do
          parking_plan = Image.find(parking_plan_id)
          old_image = url_for(parking_plan.file)
          old_name = parking_plan.meta_name
          subject
          parking_plan.reload
          expect(old_name).not_to eq(parking_plan.meta_name)
          expect(old_image).not_to eq(url_for(parking_plan.file))

        end
      end

    end

    context 'fail: invalid params' do
      context 'parking admin doesn\'t belong to parking lot' do
        subject do
          put "/api/dashboard/parking_lots/#{parking_lot.id}/parking_plans/#{parking_plan_id}", headers: { Authorization: get_auth_token(parking_admin) }        end
        it_behaves_like 'response_403', :show_in_doc
      end
      context 'town manager doesn\'t belong to parking lot' do
        subject do
          put "/api/dashboard/parking_lots/#{parking_lot.id}/parking_plans/#{parking_plan_id}", headers: { Authorization: get_auth_token(town_manager) }
        end
        it_behaves_like 'response_403', :show_in_doc
      end

    end
  end
end
