require 'rails_helper'

RSpec.describe Api::Dashboard::CamerasController, type: :request do
  let!(:admin) { create(:admin, role: super_admin_role) }
  let!(:lot) { create(:parking_lot) }

  describe 'GET #create' do
    subject do
      post "/api/dashboard/cameras",
          headers: { Authorization: get_auth_token(admin) },
          params: {
            camera: {
              name: 'test name',
              login: 'qwe',
              vmarkup: Base64.encode64(File.read(Rails.root.join('spec/fixtures/camera.vmarkup'))),
              password: 'qweqweqwe',
              stream: Faker::Internet.url(Faker::Internet.ip_v4_address, '/MediaInput/stream_1', 'rtsp'),
              parking_lot_id: lot.id
            }
          }
    end

    it_behaves_like 'response_201', :show_in_doc
  end
end
