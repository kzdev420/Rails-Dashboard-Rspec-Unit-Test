require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  describe 'GET #me' do
    let!(:user) { create(:user, :confirmed, :with_vehicles) }

    context 'success' do
      subject do
        get '/api/v1/users/me', headers: { Authorization: get_auth_token(user) }
      end

      it 'should answer with user fields' do
        subject
        [:email, :first_name, :last_name, :created_at, :phone].each do |key|
          expect(json[key].present?).to eq(true)
        end
        expect(json[:vehicles_attributes].size).to eq(user.active_vehicles.count)
      end

      it_behaves_like 'response_200', :show_in_doc
    end

    context 'fail' do
      context 'unconfirmed' do
        let!(:unconfirmed_user) { create(:user) }
        subject do
          get '/api/v1/users/me', headers: { Authorization: get_auth_token(unconfirmed_user) }
        end

        it_behaves_like 'response_403', :show_in_doc
      end

      context 'unauthorized' do
        subject do
          get '/api/v1/users/me'
        end

        it_behaves_like 'response_401', :show_in_doc
      end
    end
  end
end
