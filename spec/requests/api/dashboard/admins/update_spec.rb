require 'rails_helper'

RSpec.describe Api::Dashboard::AdminsController, type: :request do
  describe 'PUT #update' do
    let!(:admin) { create(:admin, role: super_admin_role) }
    let!(:manager) { create(:admin, role: manager_role) }
    let!(:officer) { create(:admin, role: officer_role) }

    let(:valid_params) do
      {
        email: Faker::Internet.email,
        username: Faker::Admin.username,
        status: 'suspended',
        phone: Faker::Phone.number,
        role_id: manager_role.id,
        name: Faker::Name.first_name,
      }
    end

    context 'success: by admin' do
      subject do
        put "/api/dashboard/admins/#{manager.id}", headers: { Authorization: get_auth_token(admin) }, params: {
          admin: valid_params
        }
      end

      it_behaves_like 'response_200', :show_in_doc

      it 'should update manager' do
        subject
        manager.reload
        expect(manager.name).to eq(valid_params[:name])
        expect(manager.email).to eq(valid_params[:email])
        expect(manager.phone).to eq(valid_params[:phone])
        expect(manager.role_id).to eq(valid_params[:role_id])
        expect(manager.status).to eq(valid_params[:status])
      end
    end

    context 'fail: invalid params' do
      subject do
        put "/api/dashboard/admins/#{manager.id}", headers: { Authorization: get_auth_token(admin) }, params: {
          admin: {
            email: 'invalid',
            username: '',
            phone: '+1',
            role_id: Role.last.id,
            name: 'Paul',
            status: '11111'
          }
        }
      end

      it_behaves_like 'response_422', :show_in_doc
    end

    context 'fail: role id empty' do
      let!(:another_manager) { create(:admin, role: manager_role) }
      subject do
        put "/api/dashboard/admins/#{manager.id}", headers: { Authorization: get_auth_token(another_manager) }
      end

      it_behaves_like 'response_422'
    end
  end
end
