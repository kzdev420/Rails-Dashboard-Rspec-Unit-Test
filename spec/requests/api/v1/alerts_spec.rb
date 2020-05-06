require 'rails_helper'

RSpec.describe Api::V1::AlertsController, type: :request do
  let!(:user) { create(:user, :confirmed) }

  describe 'GET #index' do
    before do
      create_list(:alert, 10, user: user)
      create_list(:alert, 10, user: user, status: :resolved)
    end

    subject { get '/api/v1/alerts', headers: { Authorization: get_auth_token(user) } }

    it_behaves_like 'response_200', :show_in_doc

    it 'returns only opened alerts' do
      subject
      expect(json.size).to eq(10)
    end
  end

  describe 'GET #resolve' do
    let!(:alert) { create(:alert, user: user) }
    subject { get "/api/v1/alerts/#{alert.id}/resolve", headers: { Authorization: get_auth_token(user) } }

    it_behaves_like 'response_200', :show_in_doc

    it 'becomes resolved' do
      subject
      expect(alert.reload).to be_resolved
    end
  end
end
