require 'rails_helper'

RSpec.describe Api::Dashboard::Parking::VehicleRulesController, type: :request do
  let!(:admin) { create(:admin, role: super_admin_role) }
  let!(:lot) { create(:parking_lot) }
  let!(:rule) { create(:parking_vehicle_rule, lot: lot) }

  subject do
    put "/api/dashboard/parking/lots/#{lot.id}/vehicle_rules/#{rule.id}",
        headers: { Authorization: get_auth_token(admin) },
        params: {
          vehicle_rule: {
            color: 'red',
            vehicle_type: 'crossover'
          }
        }
  end

  describe 'PUT #update' do
    context 'success' do
      it_behaves_like 'response_200', :show_in_doc
    end
  end
end
