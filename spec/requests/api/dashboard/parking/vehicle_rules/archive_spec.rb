require 'rails_helper'

RSpec.describe Api::Dashboard::Parking::VehicleRulesController, type: :request do
  let!(:admin) { create(:admin, role: super_admin_role) }
  let!(:lot) { create(:parking_lot) }

  subject do
    put "/api/dashboard/parking/lots/#{lot.id}/vehicle_rules/archive",
        headers: { Authorization: get_auth_token(admin) },
        params: { rule_ids: rule_ids }
  end

  before do
    create_list(:parking_vehicle_rule, 10, lot: lot)
  end

  describe 'PUT #archive' do
    context 'success' do
      let(:rule_ids) { Parking::VehicleRule.pluck(:id) }
      it_behaves_like 'response_200', :show_in_doc
    end

    context 'failure' do
      let(:rule_ids) { [999, 333, 777] }
      it_behaves_like 'response_404', :show_in_doc
    end
  end
end
