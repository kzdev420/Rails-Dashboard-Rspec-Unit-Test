require 'rails_helper'

RSpec.describe Api::Dashboard::CamerasController, type: :request do
  describe 'GET #index' do
    let!(:admin) { create(:admin, role: super_admin_role) }
    let!(:manager) { create(:admin, role: manager_role) }
    let!(:lot) { create(:parking_lot) }

    subject do
      get '/api/dashboard/cameras',
          headers: { Authorization: get_auth_token(admin) },
          params: { parking_lot_id: lot.id }
    end

    before do
      create_list(:camera, 10)
      create(:camera, allowed: false,  parking_lot: lot)
      create_list(:camera, 10, parking_lot: lot)
    end

    it_behaves_like 'response_200', :show_in_doc

    it 'returns 10 cameras' do
      subject
      expect(json.size).to eq(11)
    end

    context 'fails to retrieve some cameras' do

      subject do
        get '/api/dashboard/cameras',
          headers: { Authorization: get_auth_token(manager) },
          params: { parking_lot_id: lot.id }
      end

      it 'should not allow other than admins to see the new camera' do
        create(:camera, allowed: false,  parking_lot: lot)
        subject
        expect(json.size).to eq(10)
      end
    end
  end
end
