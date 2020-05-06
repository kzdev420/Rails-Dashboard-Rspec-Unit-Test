require 'rails_helper'

RSpec.describe Api::Dashboard::AuthController, type: :request do
  describe 'POST #send_reset_password_instructions' do
    let!(:admin) { create(:admin) }

    context 'success' do
      subject do
        post '/api/dashboard/auth/send_reset_password_instructions', params: { admin: { username: admin.email } }
      end

      it_behaves_like 'response_201', :show_in_doc

      it 'should send reset password instructions' do
        expect(admin.reset_password_token).to eq(nil)
        expect(AdminMailer).to receive(:reset_password_instructions)
          .and_return( double("AdminMailer", deliver_later: true) ).once
        subject
        expect(admin.reload.reset_password_token.present?).to eq(true)
      end
    end

    context 'fail' do
      subject do
        post '/api/dashboard/auth/send_reset_password_instructions', params: { admin: { username: 'sssss' } }
      end

      it_behaves_like 'response_422', :show_in_doc
    end
  end

  describe 'POST #reset_password' do
    let!(:admin) { create(:admin) }

    context 'success' do
      subject do
        put '/api/dashboard/auth/reset_password', params: { admin: {
          password: 'new_password',
          reset_password_token: admin.send_reset_password_instructions
        } }
      end

      it_behaves_like 'response_200', :show_in_doc

      it 'should update admin password' do
        subject
        expect(admin.reload.valid_password?('new_password')).to eq(true)
      end
    end

    context 'fail' do
      subject do
        put '/api/dashboard/auth/reset_password', params: { admin: {
          password: 'new_password',
          reset_password_token: 'invalid_token'
        } }
      end

      it_behaves_like 'response_422', :show_in_doc

      it 'should have error' do
        subject
        expect(json[:errors][:reset_password_token].present?).to eq(true)
      end
    end
  end
end
