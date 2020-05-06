require 'rails_helper'

RSpec.describe Api::Dashboard::Parking::VehicleRulesController, type: :request do
  let!(:admin) { create(:admin, role: super_admin_role) }
  let!(:lot) { create(:parking_lot) }

  subject do
    get "/api/dashboard/parking/lots/#{lot.id}/vehicle_rules",
        headers: { Authorization: get_auth_token(admin) }
  end

  before do
    create_list(:parking_vehicle_rule, 10, lot: lot)
  end

  describe 'GET #index' do
    context 'success' do
      it_behaves_like 'response_200', :show_in_doc
    end
  end
end
