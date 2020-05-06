require 'rails_helper'

describe Api::V1::Ksk::ParkingSessionsController, type: :request do
  let!(:auth_token) { create(:ksk_token).value }

  describe 'GET #index' do
    let!(:session) { create(:parking_session, check_out: nil) }

    context 'by plate number' do
      context 'success' do
        subject do
          get '/api/v1/ksk/parking_sessions',
              headers: { Authorization: auth_token },
              params: { plate_number: session.vehicle.plate_number.upcase }
        end

        it_behaves_like 'response_200'
      end

      context 'fail' do
        subject do
          get '/api/v1/ksk/parking_sessions',
              headers: { Authorization: auth_token },
              params: { plate: 'invalid' }
        end

        it_behaves_like 'response_404', :show_in_doc
      end
    end

    context 'by parking slot' do
      context 'success' do
        subject do
          get '/api/v1/ksk/parking_sessions',
              headers: { Authorization: auth_token },
              params: { parking_slot_id: session.parking_slot.name }
        end

        it_behaves_like 'response_200', :show_in_doc

        it 'has required attributes' do
          subject
          [
            :id,
            :check_in,
            :check_out,
            :lot,
            :slot,
            :status,
            :total_price,
            :paid
          ].each do |a|
            expect(json.has_key?(a)).to eq(true)
          end
        end
      end
    end
  end

  describe 'PUT #confirm' do
    let!(:session) { create(:parking_session) }
    let!(:next_check_out) { 2.hours.from_now.to_i }

    context 'success' do
      subject do
        Sidekiq::Testing.fake! do
          put "/api/v1/ksk/parking_sessions/#{session.id}/confirm",
              headers: { Authorization: auth_token },
              params: { parking_session: { check_out: next_check_out } }
        end
      end

      it_behaves_like 'response_200'

      it 'should update session' do
        subject
        expect(session.reload.check_out.present?).to eq(true)
        expect(session.confirmed?).to eq(true)
      end

      it 'should answer with updated session' do
        subject
        expect(json[:check_out]).to eq(next_check_out)
        expect(json[:paid]).to eq(true)
      end
    end
  end

  describe 'GET #show' do
    let!(:session) { create(:parking_session) }

    context 'success' do
      subject do
        get "/api/v1/ksk/parking_sessions/#{session.id}", headers: { Authorization: auth_token }
      end

      it_behaves_like 'response_200', :show_in_doc
    end
  end

  describe 'GET #payment' do
    let!(:session) { create(:parking_session) }

    subject do
      get "/api/v1/ksk/parking_sessions/#{session.id}/payment",
          headers: { Authorization: auth_token },
          params: { check_out: '1800' }
    end

    it_behaves_like 'response_200', :show_in_doc
  end
end
