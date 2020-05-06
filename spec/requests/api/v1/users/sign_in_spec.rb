require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  describe 'POST #sign_in' do
    let(:password) { '12345678' }
    let!(:user) do
      user = create(:user, :confirmed, password: password)
    end
    let(:valid_params) do
      {
        email: user.email,
        password: password
      }
    end

    context 'success' do
      subject do
        post '/api/v1/users/sign_in', params: { user: valid_params }
      end

      it 'should create new user token' do
        expect { subject }.to change(User::Token, :count).by(1)
      end

      it_behaves_like 'response_201', :show_in_doc

      it 'should answer with valid auth token' do
        subject
        token = json[:token]
        expect(token.present?).to eq(true)
        expect(::Authorizer.authorize_by_token(token, User)).to eq(user)
      end

      context 'uppercase' do
        let(:valid_params) do
          {
            email: user.email.upcase,
            password: password
          }
        end

        subject do
          post '/api/v1/users/sign_in', params: { user: valid_params }
        end

        it 'should be able to sign in with uppercase email'  do
          subject
          token = json[:token]
          expect(token.present?).to eq(true)
          expect(::Authorizer.authorize_by_token(token, User)).to eq(user)
        end
      end

    end

    context 'fail' do
      context 'when invalid email' do
        subject do
          params = valid_params
          params[:email] = 'invalid@mail.com'
          post '/api/v1/users/sign_in', params: { user: params }
        end

        it_behaves_like 'response_422', :show_in_doc

        it 'should have error about email' do
          subject
          expect(json[:errors][:email].present?).to eq(true)
        end
      end

      context 'when invalid password' do
        subject do
          params = valid_params
          params[:password] = 'invalid_password'
          post '/api/v1/users/sign_in', params: { user: params }
        end

        it_behaves_like 'response_422', :show_in_doc

        it 'should have error about password' do
          subject
          expect(json[:errors][:password].present?).to eq(true)
        end
      end

      context 'when user is unconfirmed' do
        let!(:unconfirmed_user) { create(:user, password: password) }

        subject do
          params = {
            email: unconfirmed_user.email,
            password: password
          }
          post '/api/v1/users/sign_in', params: { user: params }
        end

        it 'should answer with error about confirmation', :show_in_doc do
          subject
          expect(json[:errors][:base].present?).to eq(true)
        end
      end
    end
  end
end
