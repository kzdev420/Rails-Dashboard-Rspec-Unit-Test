require 'rails_helper'

RSpec.describe Api::Dashboard::AdminsController, type: :request do
  describe 'POST #create' do
    let!(:admin) { create(:admin, role: super_admin_role) }
    let(:valid_params) do
      {
        email: Faker::Internet.email,
        username: Faker::Admin.username,
        status: 'active',
        avatar: fixture_base64_file_upload('spec/files/test.jpg'),
        phone: Faker::Phone.number,
        role_id: manager_role.id,
        name: Faker::Name.first_name,
      }
    end

    context 'success' do
      subject do
        post '/api/dashboard/admins', headers: { Authorization: get_auth_token(admin) }, params: {
          admin: valid_params
        }
      end

      it_behaves_like 'response_201', :show_in_doc

      it 'should create new record' do
        expect { subject }.to change(Admin, :count).by(1)
      end

      it 'should send email' do
        expect(AdminMailer).to receive(:user_created)
          .and_return( double("AdminMailer", deliver_later: true) ).once
        expect(AdminMailer).to receive(:welcome_letter)
          .and_return( double("AdminMailer", deliver_later: true) ).once
        subject
      end
    end

    context 'fail: invalid params' do
      subject do
        post '/api/dashboard/admins', headers: { Authorization: get_auth_token(admin) }, params: {
          admin: {
            email: 'invalid',
            username: '',
            phone: '+1',
            role_id: Role.second.id,
            name: 'Paul',
            status: '11111'
          }
        }
      end

      it_behaves_like 'response_422', :show_in_doc
    end

    context 'fail: access denied' do
      let!(:manager) { create(:admin, role: manager_role) }
      subject do
        post '/api/dashboard/admins', headers: { Authorization: get_auth_token(manager) }, params: {
          admin: {
            role_id: Role.find_by(name: 'system_admin').id
          }
        }
      end

      it_behaves_like 'response_403'
    end
  end
end
