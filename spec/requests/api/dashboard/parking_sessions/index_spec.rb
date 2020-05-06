require 'rails_helper'

RSpec.describe Api::Dashboard::ParkingSessionsController, type: :request do
  let!(:admin) { create(:admin, role: super_admin_role) }
  let(:vehicle) { create(:vehicle) }

  let!(:parking_lot) { create(:parking_lot) }

  let!(:slots) { create_list(:parking_slot, 4, parking_lot: parking_lot) }

  let!(:parking_sessions_payed_cash) do
    create_list(
      :parking_session,
      2,
      :with_cash_payment,
      parking_lot: parking_lot,
      parking_slot: slots.sample,
      parked_at: Time.now,
      kiosk: create(:kiosk),
      status: :confirmed,
      check_in: Time.now,
      check_out: 1.hour.from_now,
      fee_applied:  parking_lot.rate
    )
  end

  let!(:parking_session_with_user) do
    create_list(:parking_session, 2, parking_lot: parking_lot, parking_slot: slots.sample, parked_at: Time.now, vehicle: vehicle)
  end

  let!(:parking_sessions_parked) do
    create_list(:parking_session, 4, parking_lot: parking_lot, parking_slot: slots.sample, parked_at: Time.now)
  end

  let!(:parking_sessions_entered) { create_list(:parking_session, 4, parking_lot: parking_lot, parking_slot: nil) }

  let!(:params) do
    @params = { parking_lot_id: parking_lot.id }
  end

  describe 'GET #index' do
    context 'success' do

      subject do
        get "/api/dashboard/parking_sessions/", headers: { Authorization: get_auth_token(admin) }, params: @params
      end

      it_behaves_like 'response_200', :show_in_doc

      it 'should return 404 if parking lot is not specified' do
        @params = {}
        subject
        expect(status).to eq(404)
      end

      it 'should returns all sessions associate to parking lot which has parked' do
        subject
        json.each do |session|
          parking_sessions_parked.map(&:id).include?(session["id"])
        end
        size = parking_session_with_user.size + parking_sessions_parked.size + parking_sessions_payed_cash.size
        expect(size).to eq(json.size)
      end

      it 'should return one session if parking sessions ID is specified' do
        @params = {
          parking_lot_id: parking_lot.id,
          parking_session_id: parking_sessions_parked.sample.id
        }
        subject
        expect(json.size).to eq(1)
      end

      it 'should return session with payments method specified' do
        @params = {
          parking_lot_id: parking_lot.id,
          payment_methods: [Payment.payment_methods[:cash]]
        }
        subject
        expect(parking_sessions_payed_cash.size).to eq(json.size)

      end

      it 'should return session with statuses specified' do
        @params = {
          parking_lot_id: parking_lot.id,
          statuses: [ParkingSession.statuses[:confirmed]]
        }
        subject
        expect(parking_sessions_payed_cash.size).to eq(json.size)

      end

      it 'should return sessions associated to an account' do
        @params = {
          parking_lot_id: parking_lot.id,
          user_ids: [vehicle.user.id]
        }
        subject
        expect(parking_session_with_user.size).to eq(json.size)
      end

      it 'should return sessions associated to kiosk' do
        @params = {
          parking_lot_id: parking_lot.id,
          kiosk_ids: [Kiosk.first.id]
        }
        subject
        expect(parking_sessions_payed_cash.size).to eq(json.size)
      end

      it 'should return sessions associated to slot name' do
        slot_name = slots.sample.name
        sessions = ParkingSession.joins(:parking_slot).where(parking_slots: { name: slot_name } )
        @params = {
          parking_lot_id: parking_lot.id,
          slot_name: slot_name
        }
        subject
        expect(sessions.size).to eq(json.size)
      end

      it 'should return sessions with a specific fee' do
        @params = {
          parking_lot_id: parking_lot.id,
          fee_applied: parking_lot.rate
        }
        subject
        expect(parking_sessions_payed_cash.size).to eq(json.size)
      end

      it 'should return sessions with a specific total price' do
        @params = {
          parking_lot_id: parking_lot.id,
          total_price: parking_lot.rate
        }
        subject
        expect(parking_sessions_payed_cash.size).to eq(json.size)
      end

      it 'should return sessions with a specific vehicle'  do
        @params = {
          parking_lot_id: parking_lot.id,
          query: {
            vehicles: {
              plate_number: vehicle.plate_number
            }
          }
        }
        subject
        expect(parking_session_with_user.size).to eq(json.size)
      end

      context 'ranges' do
        let!(:params) do
          @params = {
            parking_lot_id: parking_lot.id,
            created_at: {
              from: Date.today.strftime("%Y-%-m-%-d"),
              to: Date.today.strftime("%Y-%-m-%-d")
            },
            check_in: {
              from: Date.today.strftime("%Y-%-m-%-d"),
              to: Date.today.strftime("%Y-%-m-%-d")
            },
            check_out: {
              from: Date.today.strftime("%Y-%-m-%-d"),
              to: Date.today.strftime("%Y-%-m-%-d")
            }
          }
        end

        it_behaves_like 'response_200'
      end
    end
  end
end
