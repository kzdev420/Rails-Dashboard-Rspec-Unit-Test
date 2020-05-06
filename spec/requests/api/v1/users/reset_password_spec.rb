require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  describe 'PUT #reset_password' do
    let!(:user) { create(:user) }

    context 'success' do
      subject do
        put '/api/v1/users/reset_password', params: { user: {
          password: 'new_password',
          reset_password_token: user.send_reset_password_instructions
        } }
      end

      it 'should update user password' do
        subject
        expect(user.reload.valid_password?('new_password')).to eq(true)
      end

      it 'should notify user about password change' do
        expect(UserMailer).to receive(:password_change)
          .and_return( double("UserMailer", deliver_later: true) ).once
        subject
      end

      it_behaves_like 'response_200', :show_in_doc
    end

    context 'fail' do
      context 'token is invalid' do

        subject do
          put '/api/v1/users/reset_password', params: { user: {
            password: 'new_password',
            reset_password_token: 'invalid_token'
          } }
        end

        it_behaves_like 'response_422', :show_in_doc

        it 'should contain token error' do
          subject
          expect(json[:errors][:reset_password_token].present?).to eq(true)
        end

      end

      context 'password is invalid' do
        subject do
          put '/api/v1/users/reset_password', params: { user: {
            password: '123',
            reset_password_token: user.send_reset_password_instructions
          } }

          it_behaves_like 'response_422', :show_in_doc

          it 'should contain password error' do
            subject
            expect(json[:errors][:password].present?).to eq(true)
          end
        end
      end
    end
  end

  describe 'POST #send_reset_password_instructions' do
    let!(:user) { create(:user) }

    context 'success' do
      subject do
        post '/api/v1/users/send_reset_password_instructions', params: { user: { email: user.email } }
      end

      it_behaves_like 'response_200', :show_in_doc

      it 'should send instructions mail' do
        expect(UserMailer).to receive(:reset_password_instructions)
          .and_return( double("UserMailer", deliver_later: true) ).once
        expect(user.reset_password_token.nil?).to eq(true)
        subject
        expect(user.reload.reset_password_token.present?).to eq(true)
      end
    end

    context 'fail' do
      context 'invalid email' do
        subject do
          post '/api/v1/users/send_reset_password_instructions', params: { user: { email: 'invalid@mail.com' } }
        end

        it_behaves_like 'response_404', :show_in_doc
      end
    end
  end
end
