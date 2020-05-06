require 'rails_helper'

RSpec.describe Api::Dashboard::ParkingLotsController, type: :request do
  let!(:lots) { create_list(:parking_lot, 2) }
  let!(:admin) { create(:admin, role: super_admin_role) }
  let!(:parking_admin) { create(:admin, role: parking_admin_role) }
  let!(:new_parking_admin) { create(:admin, role: parking_admin_role) }
  let!(:town_manager) { create(:admin, role: town_manager_role) }
  let!(:lot_3) { create(:parking_lot, admins: [parking_admin, town_manager]) }
  let!(:lot_4) { create(:parking_lot, admins: [town_manager]) }

  describe 'GET #index' do
    context 'success: by super_admin' do
      subject do
        get '/api/dashboard/parking_lots', headers: { Authorization: get_auth_token(admin) }
      end

      it_behaves_like 'response_200', :show_in_doc

      it 'should have 4 items' do
        subject
        expect(json.size).to eq(4)
      end
    end

    context 'success: by parking admin' do
      subject do
        get '/api/dashboard/parking_lots', headers: { Authorization: get_auth_token(parking_admin) }
      end

      it_behaves_like 'response_200'

      it 'should have 1 item' do
        subject
        expect(json.size).to eq(1)
      end
    end

    context 'success: by parking admin' do
      subject do
        get '/api/dashboard/parking_lots', headers: { Authorization: get_auth_token(new_parking_admin) }
      end

      it_behaves_like 'response_200'

      it 'should have 0 item' do
        subject
        expect(json.size).to eq(0)
      end
    end

    context 'success: by town manager' do
      subject do
        get '/api/dashboard/parking_lots', headers: { Authorization: get_auth_token(town_manager) }
      end

      it_behaves_like 'response_200'

      it 'should have 2 items' do
        subject
        expect(json.size).to eq(2)
      end
    end

    context 'success: by query' do
      subject do
        get '/api/dashboard/parking_lots',
            headers: { Authorization: get_auth_token(admin) },
            params: {
              query: {
                parking_lots: {
                  name: lots.first.name[0..-2]
                }
              }
            }
      end

      it_behaves_like 'response_200', :show_in_doc
    end
  end
end
