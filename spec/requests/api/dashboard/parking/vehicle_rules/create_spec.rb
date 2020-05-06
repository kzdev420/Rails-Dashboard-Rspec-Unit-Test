require 'rails_helper'

RSpec.describe Api::Dashboard::Parking::VehicleRulesController, type: :request do
  let!(:admin) { create(:admin, role: super_admin_role) }
  let!(:lot) { create(:parking_lot) }

  subject do
    post "/api/dashboard/parking/lots/#{lot.id}/vehicle_rules",
         headers: { Authorization: get_auth_token(admin) },
         params: {
           vehicle_rule: params
         }
  end

  describe 'POST #create' do
    context 'success' do
      context 'from vehicle id' do
        let(:params) do
          {
            vehicle_id: create(:vehicle).id
          }
        end

        it_behaves_like 'response_201', :show_in_doc
      end

      context 'from plate number' do
        let(:params) do
          {
            plate_number: create(:vehicle).plate_number
          }
        end

        it_behaves_like 'response_201', :show_in_doc
      end

      context 'from attributes' do
        let(:params) do
          {
            color: Faker::Vehicle.color,
            vehicle_type: Faker::Vehicle.car_type
          }
        end

        it_behaves_like 'response_201', :show_in_doc
      end
    end

    context 'failure' do
      context 'invalid vehicle_id' do
        let(:params) { { vehicle_id: 999 } }
        it_behaves_like 'response_422', :show_in_doc
      end

      context 'missing arguments' do
        let(:params) { { color: '', vehicle_type: '' } }
        it_behaves_like 'response_422', :show_in_doc
      end
    end
  end
end
