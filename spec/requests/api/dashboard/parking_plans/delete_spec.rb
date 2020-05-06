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
    lot.parking_plans.create(file: { data: fixture_base64_file_upload('spec/files/test.jpg') })
    lot.parking_plans.create(file: { data: fixture_base64_file_upload('spec/files/test.jpg') })
    lot
  end

  let(:parking_plan_id) { parking_lot.parking_plans.first.id }

  describe 'DELETE #destroy' do
    context 'success' do
      subject do
        delete "/api/dashboard/parking_lots/#{parking_lot.id}/parking_plans/#{parking_plan_id}", headers: { Authorization: get_auth_token(admin) }
      end

      it_behaves_like 'response_200', :show_in_doc

      it 'deletes parking lot plan' do
        expect(Image.count).to eq(2)
        subject
        expect(parking_lot.parking_plans.count).to eq(1)
        expect(Image.count).to eq(1)
      end

    end

    context 'fail: invalid params' do
      context 'parking admin doesn\'t belong to parking lot', only: true do
        subject do
          delete "/api/dashboard/parking_lots/#{parking_lot.id}/parking_plans/100", headers: { Authorization: get_auth_token(admin) }
        end
        it_behaves_like 'response_404', :show_in_doc

      end

      context 'parking admin doesn\'t belong to parking lot' do
        subject do
          delete "/api/dashboard/parking_lots/#{parking_lot.id}/parking_plans/#{parking_plan_id}", headers: { Authorization: get_auth_token(parking_admin) }
        end
        it_behaves_like 'response_403', :show_in_doc
      end
      context 'town manager doesn\'t belong to parking lot' do
        subject do
          delete "/api/dashboard/parking_lots/#{parking_lot.id}/parking_plans/#{parking_plan_id}", headers: { Authorization: get_auth_token(town_manager) }
        end
        it_behaves_like 'response_403', :show_in_doc
      end

    end
  end
end
