require 'rails_helper'

RSpec.describe Api::Dashboard::AgenciesController, type: :request do
  let!(:admin) { create(:admin, role: super_admin_role) }
  let!(:town_manager) { create(:admin, role: town_manager_role) }
  let!(:manager) { create(:admin, role: manager_role) }
  let!(:agencies) { create_list(:agency, 20) }

  describe 'GET #index' do
    context 'success' do
      subject do
        get '/api/dashboard/agencies', headers: { Authorization: get_auth_token(admin) }
      end

      it_behaves_like 'response_200', :show_in_doc

      it 'should  return all the agencies' do
        subject
        expect(response.headers['X-Total']).to eq(Agency.count.to_s)
      end
    end

    context 'success' do
      let!(:new_agencies) { create_list(:agency, 2, town_managers: [town_manager]) }

      subject do
        get '/api/dashboard/agencies', headers: { Authorization: get_auth_token(town_manager) }
      end

      it 'should only return the agencies where the user is currently in' do
        subject
        expect(json.size).to eq(2)
      end
    end

    context 'success: manager filter' do
      subject do
        agencies.last.update(managers: [manager])
        get '/api/dashboard/agencies', headers: { Authorization: get_auth_token(manager) }, params: {
          manager_id: manager.id
        }
      end

      it_behaves_like 'response_200'

      it 'should have 1 item in response' do
        subject
        expect(json.size).to eq(1)
      end
    end

    context 'sucess: query with location substring' do
      let(:query) { { locations: { full_address: agencies.last.location.full_address.first(5) } } }

      subject do
        get '/api/dashboard/agencies', headers: { Authorization: get_auth_token(admin) }, params: {
          query: query
        }
      end

      it 'should have corresponding items in response', :show_in_doc do
        subject
        expect(json.map { |a| a.dig('location', 'full_address').include?(query[:locations][:full_address]) }.include?(false) ).to eq(false)
      end
    end

    context 'success: by query and status' do
      let(:query) { { "agencies.name": agencies.last.name.first(5) } }

      subject do
        get '/api/dashboard/agencies', headers: { Authorization: get_auth_token(admin) }, params: {
          query: query, status: 'suspended'
        }
      end

      it_behaves_like 'response_200'

      it 'shoudnt have items in response' do
        subject
        expect(json.size).to eq(0)
      end
    end
  end
end
