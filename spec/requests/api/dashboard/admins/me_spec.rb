require 'rails_helper'

RSpec.describe Api::Dashboard::AdminsController, type: :request do
  describe 'GET #me' do
    let!(:admin) { create(:admin, role: super_admin_role) }

    context 'success' do
      subject do
        get "/api/dashboard/admins/me", headers: { Authorization: get_auth_token(admin) }
      end

      it_behaves_like 'response_200', :show_in_doc

      it 'should fetch admin info' do
        subject
        expect(json[:id]).to eq(admin.id)
      end
    end
  end
end
