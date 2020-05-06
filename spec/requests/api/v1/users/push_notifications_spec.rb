require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  describe 'POST #push_notification_token' do
    let!(:user) { create(:user, :confirmed, :with_vehicles) }
    let(:push_notification_token) { '123456789:abcdef' }

    context 'success' do
      subject do
        post '/api/v1/users/push_notification_token', headers: { Authorization: get_auth_token(user) }, params: { user: { push_notification_token: push_notification_token } }
      end

      it_behaves_like 'response_201', :show_in_doc

      it 'should add a push_notification_token' do
        expect { subject }.to change(User::PushNotificationToken, :count).by(1)
      end

    end

    context 'fail' do
      context 'unauthorized' do
        subject do
          post '/api/v1/users/push_notification_token'
        end

        it_behaves_like 'response_401', :show_in_doc
      end
      context 'bad_request' do
        subject do
          post '/api/v1/users/push_notification_token', headers: { Authorization: get_auth_token(user) }
        end

        it_behaves_like 'response_400', :show_in_doc
      end
    end
  end
end
