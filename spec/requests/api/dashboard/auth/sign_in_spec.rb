require 'rails_helper'

RSpec.describe Api::Dashboard::AuthController, type: :request do
  describe 'POST #sign_in' do
    let(:password) { '12345678' }
    let!(:admin) do
      admin = create(:admin, password: password)
    end
    let(:valid_params) do
      {
        username: [admin.email, admin.username].sample,
        password: password
      }
    end

    context 'success' do
      subject do
        post '/api/dashboard/auth/sign_in', params: { admin: valid_params }
      end

      it 'should create new admin token' do
        expect { subject }.to change(Admin::Token, :count).by(1)
      end

      it_behaves_like 'response_201', :show_in_doc

      it 'should answer with valid auth token' do
        subject
        token = json[:token]
        expect(token.present?).to eq(true)
        expect(::Authorizer.authorize_by_token(token, Admin)).to eq(admin)
      end
    end

    context 'fail: invalid credentials' do
      context 'when invalid email' do
        subject do
          params = valid_params
          params[:username] = 'invalid@mail.com'
          post '/api/dashboard/auth/sign_in', params: { admin: params }
        end

        it_behaves_like 'response_422', :show_in_doc

        it 'should have error about username' do
          subject
          expect(json[:errors][:username].present?).to eq(true)
        end
      end

      context 'when invalid password' do
        subject do
          params = valid_params
          params[:password] = 'invalid_password'
          post '/api/dashboard/auth/sign_in', params: { admin: params }
        end

        it_behaves_like 'response_422', :show_in_doc

        it 'should have error about password' do
          subject
          expect(json[:errors][:password].present?).to eq(true)
        end
      end
    end

    context 'fail: suspended account' do
      subject do
        admin.suspended!
        post '/api/dashboard/auth/sign_in', params: { admin: valid_params }
      end

      it 'should have error about suspended account' do
        subject
        expect(json[:errors][:base].present?).to eq(true)
      end

      it_behaves_like 'response_422', :show_in_doc
    end
  end
end
