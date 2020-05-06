require 'rails_helper'

RSpec.describe Api::Dashboard::CamerasController, type: :request do
  let!(:camera) { create(:camera) }
  let!(:admin) { create(:admin, role: super_admin_role) }
  let!(:manager) { create(:admin, role: manager_role) }

  describe 'GET #show' do
    subject do
      get "/api/dashboard/cameras/#{camera.id}", headers: { Authorization: get_auth_token(admin) }
    end

    it_behaves_like 'response_200', :show_in_doc

    context 'forbbiden for non admin user' do
      let!(:camera_forbbiden) { create(:camera, allowed: false) }

      subject do
        get "/api/dashboard/cameras/#{camera_forbbiden.id}", headers: { Authorization: get_auth_token(manager) }
      end

      it_behaves_like 'response_403', :show_in_doc
    end

    context 'admin user should be able to see not allowed cameras' do
      let!(:camera_forbbiden) { create(:camera, allowed: false) }

      subject do
        get "/api/dashboard/cameras/#{camera_forbbiden.id}", headers: { Authorization: get_auth_token(admin) }
      end

      it_behaves_like 'response_200', :show_in_doc
    end

  end
end
