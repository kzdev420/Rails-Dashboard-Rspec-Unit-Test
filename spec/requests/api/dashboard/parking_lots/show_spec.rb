require 'rails_helper'

RSpec.describe Api::Dashboard::ParkingLotsController, type: :request do
  let!(:admin) { create(:admin, role: super_admin_role) }
  let!(:parking_admin) { create(:admin, role: parking_admin_role) }
  let!(:town_manager) { create(:admin, role: town_manager_role) }
  let!(:parking_lot) { create(:parking_lot, admins: [parking_admin, town_manager]) }

  describe 'GET #show' do
    context 'success' do
      ['admin', 'parking_admin', 'town_manager'].each do |admin_account|
        subject do
          get "/api/dashboard/parking_lots/#{parking_lot.id}", headers: { Authorization: get_auth_token(send(admin_account)) }
        end

        it_behaves_like 'response_200', :show_in_doc
      end
    end

    context 'failure' do
      let!(:new_town_manager) { create(:admin, role: town_manager_role) }
      let!(:new_parking_admin) { create(:admin, role: parking_admin_role) }
      ['new_parking_admin','new_town_manager'].each do |forbidden_account|
        subject do
          get "/api/dashboard/parking_lots/#{parking_lot.id}", headers: { Authorization: get_auth_token(send(forbidden_account)) }
        end

        it_behaves_like 'response_403'
      end
    end

  end
end
