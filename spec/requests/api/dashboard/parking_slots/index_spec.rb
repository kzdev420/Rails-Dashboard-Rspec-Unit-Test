require 'rails_helper'

PARKING_SLOT_AMOUNT = 10

RSpec.describe Api::Dashboard::ParkingSlotsController, type: :request do
  let!(:admin) { create(:admin, role: super_admin_role) }

  let!(:parking_lot) do
    lot = create(:parking_lot)
    lot.admins = [
      create(:admin, role: parking_admin_role),
      create(:admin, role: town_manager_role)
    ]
    lot
  end
  let!(:parking_slot) { create_list(:parking_slot, PARKING_SLOT_AMOUNT, parking_lot: parking_lot) }

  context 'Success' do
    subject do
      get "/api/dashboard/parking_lots/#{parking_lot.id}/parking_slots", headers: { Authorization: get_auth_token(admin) }
    end

    it_behaves_like 'response_200', :show_in_doc

    it 'should return all slots' do
      subject
      expect(json.count).to eq(PARKING_SLOT_AMOUNT)
    end
  end
end