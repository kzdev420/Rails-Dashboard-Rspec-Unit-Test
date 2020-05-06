require 'rails_helper'

RSpec.describe Api::V1::DisputesController, type: :request do
  let!(:user) { create(:user, :confirmed) }
  let!(:session) { create(:parking_session) }

  describe 'POST #create' do
    subject do
      post "/api/v1/disputes",
           headers: { Authorization: get_auth_token(user) },
           params: params
    end

    before do
      session.parking_lot.admins << create(:admin, role: parking_admin_role)
    end

    context 'success' do
      let(:params) do
        {
          dispute: {
            text: Faker::Lorem.sentence,
            reason: :not_me,
            parking_session_id: session.id
          }
        }
      end

      it_behaves_like 'response_201', :show_in_doc
    end

    context 'failure' do
      let(:params) { Hash.new }

      it_behaves_like 'response_422', :show_in_doc
    end
  end
end
