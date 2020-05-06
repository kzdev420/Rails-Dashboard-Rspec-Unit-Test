require 'rails_helper'

RSpec.describe Api::Dashboard::ParkingSessionsController, type: :request do
  let!(:admin) { create(:admin, role: super_admin_role) }
  let!(:parking_admin) { create(:admin, role: parking_admin_role) }
  let!(:parking_lot) { create(:parking_lot) }

  let!(:slots) { create_list(:parking_slot, 4, parking_lot: parking_lot) }

  let!(:parking_sessions_parked) do
    create_list(:parking_session, 4, parking_lot: parking_lot, parking_slot: slots.sample, parked_at: Time.now)
  end
  let!(:parking_sessions_entered) { create_list(:parking_session, 4, parking_lot: parking_lot, parking_slot: nil) }

  let!(:params) do
    @params = { parking_lot_id: parking_lot.id }
  end

  describe 'GET #show' do
    context 'success' do

      subject do
        get "/api/dashboard/parking_sessions/#{parking_sessions_parked.first.id}", headers: { Authorization: get_auth_token(admin) }
      end

      it_behaves_like 'response_200', :show_in_doc

    end

    context 'failure' do

      context 'Session doesnt exist' do
        subject do
          get "/api/dashboard/parking_sessions/1000", headers: { Authorization: get_auth_token(admin) }
        end

        it_behaves_like 'response_404', :show_in_doc
      end

      context 'User not allowed to see session' do
        subject do
          get "/api/dashboard/parking_sessions/#{parking_sessions_parked.first.id}", headers: { Authorization: get_auth_token(parking_admin) }
        end

        it_behaves_like 'response_403'
      end
    end
  end
end
