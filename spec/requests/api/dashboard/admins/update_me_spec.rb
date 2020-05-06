require 'rails_helper'

password = '123admin123'

RSpec.describe Api::Dashboard::AdminsController, type: :request do
  describe 'PUT #update' do
    let!(:admin) { create(:admin, role: super_admin_role, password: password) }

    let(:valid_params) do
      {
        email: Faker::Internet.email,
        username: Faker::Admin.username,
        phone: Faker::Phone.number,
        name: Faker::Name.first_name,
      }
    end

    context 'success: by admin' do
      subject do
        put "/api/dashboard/admins/me", headers: { Authorization: get_auth_token(admin) }, params: {
          admin: valid_params
        }
      end

      it_behaves_like 'response_200', :show_in_doc

      it 'should update admin' do
        subject
        admin.reload
        expect(admin.name).to eq(valid_params[:name])
        expect(admin.email).to eq(valid_params[:email])
        expect(admin.phone).to eq(valid_params[:phone])
      end

      context 'change password' do
        let(:valid_params) do
          {
            email: admin.email,
            username: admin.username,
            name: admin.name,
            password: Faker::Internet.password,
            old_password: password
          }
        end
        it 'should update password admin' do
          old_enc_password = admin.encrypted_password
          subject
          admin.reload
          expect(admin.encrypted_password).not_to eq(old_enc_password)
        end
      end
    end

    context 'fail: invalid params' do
      subject do
        put "/api/dashboard/admins/me", headers: { Authorization: get_auth_token(admin) }, params: {
          admin: {
            email: 'invalid',
            username: '',
            phone: '+1',
            name: 'Paul'
          }
        }
      end

      it_behaves_like 'response_422', :show_in_doc

      context 'change password' do
        subject do
          put "/api/dashboard/admins/me", headers: { Authorization: get_auth_token(admin) }, params: {
            admin: invalid_params
          }
        end

        let(:invalid_params) do
          {
            email: admin.email,
            username: admin.username,
            name: admin.name,
            password: Faker::Internet.password,
            old_password: '123'
          }
        end
        it 'should update admin' do
          old_enc_password = admin.encrypted_password
          subject
          admin.reload
          expect(admin.encrypted_password).to eq(old_enc_password)
          expect(json['errors']['password'].present?).to eq(true)
        end
      end
    end
  end
end
