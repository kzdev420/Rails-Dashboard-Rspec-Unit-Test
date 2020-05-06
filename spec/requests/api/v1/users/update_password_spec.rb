require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  describe 'PUT #update_password' do

    let(:password) { '12345678' }
    let(:new_password) { '87654321' }
    let!(:user) { create(:user, :confirmed, password: password) }

    context 'success' do
      subject do
        put '/api/v1/users/update_password', headers: { Authorization: get_auth_token(user) },
          params: { user: { password: password, new_password: new_password } }
      end

      it 'should update password' do
        subject
        expect(user.reload.valid_password?(new_password))
      end

      it_behaves_like 'response_200', :show_in_doc
    end

    context 'fail' do
      context 'invalid password' do
        subject do
          put '/api/v1/users/update_password', headers: { Authorization: get_auth_token(user) },
            params: { user: { password: 'invalid_password', new_password: new_password } }
        end

        it_behaves_like 'response_422'

        it 'should contain password errors' do
          subject
          expect(json[:errors][:password].present?).to eq(true)
        end
      end
    end
  end
end
