require 'rails_helper'

RSpec.describe Api::Dashboard::CamerasController, type: :request do
  let!(:camera) { create(:camera) }
  let!(:admin) { create(:admin, role: super_admin_role) }

  describe 'GET #update' do
    subject do
      put "/api/dashboard/cameras/#{camera.id}",
          headers: { Authorization: get_auth_token(admin) },
          params: {
            camera: {
              name: 'test name',
              vmarkup: Base64.encode64(File.read(Rails.root.join('spec/fixtures/camera.vmarkup'))),
              stream: "https://google.com"
            }
          }
    end

    it_behaves_like 'response_200', :show_in_doc
  end
end
