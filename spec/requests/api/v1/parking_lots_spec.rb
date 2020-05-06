require 'rails_helper'

RSpec.describe Api::V1::ParkingLotsController, type: :request do

  let!(:lots) { create_list(:parking_lot, 20, :with_admin, :with_place) }
  let!(:user) { create(:user, :confirmed) }

  describe 'GET #index' do
    context 'success' do
      subject do
        get '/api/v1/parking_lots', headers: { Authorization: get_auth_token(user) }
      end

      it 'should contains following fields' do
        subject
        [
          :id,
          :name,
          :location,
          :available,
          :capacity,
        ].each do |a|
          expect(json.first.with_indifferent_access.has_key?(a)).to eq(true)
        end
      end

      it 'should have 10 items' do
        subject
        expect(json.size).to eq(10)
      end

      it_behaves_like 'response_200'
    end

    context 'success with per_page and page' do
      subject do
        get '/api/v1/parking_lots', headers: { Authorization: get_auth_token(user) },
            params: { per_page: 5, page: 2 }
      end
      it 'should have 5 items', :show_in_doc do
        subject
        expect(response.headers['X-Total']).to eq('20')
        expect(response.headers['X-Page']).to eq('2')
        expect(response.headers['X-Per-Page']).to eq('5')
        expect(json.size).to eq(5)
      end
    end

    context 'success with query' do
      let(:first_lot) { lots.first }
      let(:query) { first_lot.name.first(2).downcase }

      subject do
        get '/api/v1/parking_lots', headers: { Authorization: get_auth_token(user) },
            params: {
              query: query,
              status: first_lot.status,
              town_manager_id: first_lot.town_manager.id,
              parking_admin_id: first_lot.parking_admin.id
            }
      end

      it 'should have items searched by query', :show_in_doc do
        subject
        expect(json.size > 0).to eq(true)
      end
    end
  end

  describe 'GET #show' do
    context 'success' do
      subject do
        get "/api/v1/parking_lots/#{lots.first.id}", headers: { Authorization: get_auth_token(user) }
      end

      it 'should contains following fields' do
        subject
        [
          :id,
          :name,
          :available,
          :capacity,
          :rate,
          :email,
          :phone,
          :nearby_places,
          :location
        ].each do |a|
          expect(json.has_key?(a)).to eq(true)
        end
      end

      it_behaves_like 'response_200', :show_in_doc
    end
  end
end
