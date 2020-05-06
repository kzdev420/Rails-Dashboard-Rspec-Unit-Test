require 'rails_helper'

RSpec.describe Api::Dashboard::RolesController, type: :request do
  let!(:admin) { create(:admin, role: super_admin_role) }

  before do
    create_list(:role, 10)
  end

  describe 'GET #index' do
    context 'success: by super_admin' do
      subject do
        get '/api/dashboard/roles', headers: { Authorization: get_auth_token(admin) }
      end

      it_behaves_like 'response_200', :show_in_doc
    end
  end
end
