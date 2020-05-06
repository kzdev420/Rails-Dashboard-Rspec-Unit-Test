require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  describe 'PUT #confirm' do
    let(:token) { '12345678' }
    let!(:user) do
      user = create(:user, confirmation_token: token, confirmation_sent_at: Time.zone.now)
    end

    let(:valid_params) do
      { confirmation_token: token, email: user.email }
    end

    context 'success' do
      subject do
        put '/api/v1/users/confirm', params: { user: valid_params }
      end

      it 'should confirm user' do
        expect(user.confirmed?).to eq(false)
        subject
        expect(user.reload.confirmed?).to eq(true)
      end

      it_behaves_like 'response_200', :show_in_doc
    end

    context 'fail' do
      context 'when token is invalid' do
        subject do
          put '/api/v1/users/confirm', params: { user: { email: user.email, confirmation_token: 'invalid_token' } }
        end

        it_behaves_like 'response_422', :show_in_doc

        it 'shouldnt confirm user' do
          subject
          expect(user.reload.confirmed?).to eq(false)
        end

        it 'should contain token error' do
          subject
          expect(json[:errors][:confirmation_token].present?).to eq(true)
        end
      end

      context 'when confirmation period is end' do
        subject do
          user.update_column(:confirmation_sent_at, 31.days.ago)
          put '/api/v1/users/confirm', params: { user: valid_params }
        end

        it 'shouldnt confirm user', :show_in_doc do
          subject
          expect(user.reload.confirmed?).to eq(false)
        end

        it_behaves_like 'response_422'

        it 'should contain email error' do
          subject
          expect(json[:errors][:email].present?).to eq(true)
        end
      end
    end
  end

  describe 'POST #send_confirmation_instructions' do
    context 'success' do
      let(:user) { create(:user) }

      subject do
        post '/api/v1/users/send_confirmation_instructions', params: { user: { email: user.email } }
      end

      it_behaves_like 'response_200', :show_in_doc

      it 'should send instructions mail' do
        expect(UserMailer).to receive(:confirmation_instructions)
          .and_return( double("UserMailer", deliver_later: true) ).twice # twice = creating user + resending
        subject
        expect(user.reload.confirmation_token.present?).to eq(true)
      end
    end

    context 'fail' do
      context 'invalid email' do
        subject do
          post '/api/v1/users/send_confirmation_instructions', params: { user: { email: 'invalid@mail.com' } }
        end

        it_behaves_like 'response_404', :show_in_doc
      end
    end
  end
end
