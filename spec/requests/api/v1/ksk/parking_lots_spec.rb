require 'rails_helper'

describe Api::V1::Ksk::ParkingLotsController, type: :request do
  let!(:auth_token) { create(:ksk_token).value }

  describe 'GET #index' do
    subject do
      create_list(:parking_lot, 3)
      get '/api/v1/ksk/parking_lots', headers: { Authorization: auth_token }
    end

    it_behaves_like 'response_200', :show_in_doc
  end

  describe 'GET #show' do
    let!(:parking_lot) { create(:parking_lot, :with_slots) }

    before do
      parking_lot.reload.parking_slots.last.update(status: :occupied)
    end

    subject do
      get "/api/v1/ksk/parking_lots/#{parking_lot.id}", headers: { Authorization: auth_token }
    end

    it_behaves_like 'response_200', :show_in_doc

    it 'should contain required attributes' do
      subject
      [:id, :capacity, :available, :name, :address, :slots].each do |a|
        expect(json.has_key?(a)).to eq(true)
      end
    end
  end
end
