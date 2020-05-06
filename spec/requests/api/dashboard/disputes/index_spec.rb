require 'rails_helper'

RSpec.describe Api::Dashboard::DisputesController, type: :request do
  let!(:town_manager) { create(:admin, role: town_manager_role) }
  let!(:parking_admin) { create(:admin, role: parking_admin_role) }
  let!(:super_admin) { create(:admin, role: super_admin_role) }
  let!(:lot) { create(:parking_lot) }

  before do
    create_list(:dispute, 3, admin: town_manager)
    create_list(:dispute, 2, status: :pending)
    create_list(:dispute, 2, parking_session: create(:parking_session, parking_lot: lot))
    create(:dispute, parking_session: create(:parking_session, parking_lot: lot), admin: parking_admin)
  end

  describe 'GET #index' do
    context "town manager's disputes" do
      subject do
        get "/api/dashboard/disputes", headers: { Authorization: get_auth_token(town_manager) }
      end

      it_behaves_like 'response_200', :show_in_doc

      it 'returns 3 disputes' do
        subject
        expect(json.size).to eq(3)
      end
    end

    context 'pending disputes' do
      subject do
        get "/api/dashboard/disputes",
            headers: { Authorization: get_auth_token(super_admin) },
            params: { status: :pending }
      end

      it_behaves_like 'response_200', :show_in_doc

      it 'returns 2 disputes' do
        subject
        expect(json.size).to eq(2)
      end
    end

    context 'parkit lot related disputes' do
      subject do
        get "/api/dashboard/disputes",
            headers: { Authorization: get_auth_token(parking_admin) },
            params: { parking_lot_id: lot.id, admin_id: town_manager.id }
      end

      it_behaves_like 'response_200', :show_in_doc

      it 'ignores admin_id param' do
        subject
        expect(json.size).to eq(1)
      end
    end
  end
end
