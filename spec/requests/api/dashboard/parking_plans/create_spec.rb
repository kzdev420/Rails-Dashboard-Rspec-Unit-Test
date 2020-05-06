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

  let(:parking_plan_name) { 'Plan name' }

  let(:valid_params) do
    {
      parking_plan_image: fixture_base64_file_upload('spec/files/test.jpg'),
      name: parking_plan_name
    }
  end

  describe 'POST #create' do
    context 'success' do
      subject do
        post "/api/dashboard/parking_lots/#{parking_lot.id}/parking_plans", headers: { Authorization: get_auth_token(admin) }, params: valid_params
      end

      it_behaves_like 'response_201', :show_in_doc

      it 'saves parking lot plan' do
        expect { subject }.to change(Image,:count).by(1)
        parking_lot.reload
        expect(parking_lot.parking_plans.count).to eq(1)
        expect(parking_lot.parking_plans.first.meta_name).to eq(parking_plan_name)
      end

      it 'assigns a default name to parking lot plan' do
        valid_params[:name] = nil
        subject
        parking_lot.reload
        expect(parking_lot.parking_plans.first.meta_name).to eq(ParkingLots::ParkingPlan::Create::DEFAULT_NAME)
      end
    end

    context 'fail: invalid params' do
      context 'parking admin doesn\'t belong to parking lot' do
        subject do
          post "/api/dashboard/parking_lots/#{parking_lot.id}/parking_plans", headers: { Authorization: get_auth_token(parking_admin) }, params: valid_params
        end
        it_behaves_like 'response_403', :show_in_doc
      end
      context 'town manager doesn\'t belong to parking lot' do
        subject do
          post "/api/dashboard/parking_lots/#{parking_lot.id}/parking_plans", headers: { Authorization: get_auth_token(town_manager) }, params: valid_params
        end
        it_behaves_like 'response_403', :show_in_doc
      end

    end
  end
end
