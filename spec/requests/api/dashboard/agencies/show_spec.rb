require 'rails_helper'

RSpec.describe Api::Dashboard::AgenciesController, type: :request do
  let!(:admin) { create(:admin, role: super_admin_role) }
  let!(:agency) { create(:agency) }

  describe 'GET #show' do
    context 'success' do
      subject do
        get "/api/dashboard/agencies/#{agency.id}", headers: { Authorization: get_auth_token(admin) }
      end

      it_behaves_like 'response_200', :show_in_doc
    end
  end
end
