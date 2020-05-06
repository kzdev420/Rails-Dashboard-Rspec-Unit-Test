require 'rails_helper'

RSpec.describe Api::Dashboard::AuthController, type: :request do
  describe 'POST #push_notification_token' do
    let!(:user) { create(:admin) }
    let(:push_notification_token) { '123456789:abcdef' }

    context 'success' do
      subject do
        post '/api/dashboard/auth/push_notification_token', headers: { Authorization: get_auth_token(user) }, params: { admin: { push_notification_token: push_notification_token } }
      end

      it_behaves_like 'response_201', :show_in_doc

      it 'should add a push_notification_token' do
        expect { subject }.to change(Admin::PushNotificationToken, :count).by(1)
      end

    end

    context 'fail' do
      context 'unauthorized' do
        subject do
          post '/api/dashboard/auth/push_notification_token'
        end

        it_behaves_like 'response_401', :show_in_doc
      end
      context 'bad request' do
        subject do
          post '/api/dashboard/auth/push_notification_token', headers: { Authorization: get_auth_token(user) }
        end

        it_behaves_like 'response_400', :show_in_doc
      end
    end
  end
end
