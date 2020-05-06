require 'rails_helper'

RSpec.describe Api::Dashboard::AdminsController, type: :request do
  describe 'GET #show' do
    let!(:admin) { create(:admin, role: super_admin_role) }
    let!(:manager) { create(:admin, role: manager_role) }
    context 'success' do
      subject do
        get "/api/dashboard/admins/#{manager.id}", headers: { Authorization: get_auth_token(admin) }
      end

      it_behaves_like 'response_200', :show_in_doc
    end
  end
end
