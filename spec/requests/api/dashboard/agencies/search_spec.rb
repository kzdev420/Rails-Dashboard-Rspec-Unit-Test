require 'rails_helper'

RSpec.describe Api::Dashboard::AgenciesController, type: :request do
  let!(:admin) { create(:admin, role: super_admin_role) }
  let!(:manager) { create(:admin, role: manager_role) }
  let!(:agencies) { create_list(:agency, 20, status: :active) }

  describe 'GET #search' do
    context 'success' do
      subject do
        get '/api/dashboard/agencies/search', headers: { Authorization: get_auth_token(admin) }
      end

      it_behaves_like 'response_200', :show_in_doc
    end

    context 'success: by query' do
      let(:query) { { "agencies.name": agencies.last.name.first(5) } }

      subject do
        get '/api/dashboard/agencies/search', headers: { Authorization: get_auth_token(admin) }, params: {
          query: query
        }
      end

      it_behaves_like 'response_200'

      it 'should have only active agencies in response' do
        subject
        expect(Agency.where(id: json.map { |i| i['id'] })).to all(be_active)
      end
    end
  end
end
