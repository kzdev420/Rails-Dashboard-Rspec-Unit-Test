require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  let!(:user) { create(:user, :confirmed, password: 'valid_password') }

  describe 'POST #check_password' do

    context 'success' do
      subject do
        post '/api/v1/users/check_password', headers: { Authorization: get_auth_token(user) },
          params: { user: { password: 'valid_password' } }
      end

      it 'should return true', :show_in_doc do
        subject
        expect(json[:result]).to eq(true)
      end
    end

    context 'fail' do
      subject do
        post '/api/v1/users/check_password', headers: { Authorization: get_auth_token(user) },
          params: { user: { password: 'invalid_password' } }
      end

      it 'should return false', :show_in_doc do
        subject
        expect(json[:result]).to eq(false)
      end
    end
  end
end
