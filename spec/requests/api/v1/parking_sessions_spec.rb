require 'rails_helper'

RSpec.describe Api::V1::ParkingSessionsController, type: :request do
  let!(:user) { create(:user, :confirmed) }
  let!(:vehicle) { create(:vehicle, user: user) }
  let!(:parking_sessions) { create_list(:parking_session, 3, vehicle: vehicle) }

  describe 'GET #current' do
    context 'success' do
      subject do
        get '/api/v1/parking_sessions/current', headers: { Authorization: get_auth_token(user) }
      end

      it_behaves_like 'response_200', :show_in_doc

      it 'should contains following fields' do
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

    describe 'GET #payment' do
      context 'success' do
        let!(:current_session) { parking_sessions.last }
        subject do
          get "/api/v1/parking_sessions/#{current_session.id}/payment",
              headers: { Authorization: get_auth_token(user) }
        end
        it_behaves_like 'response_200', :show_in_doc

        it 'contains attributes' do
          subject
          expect(json).to include(:total_time, :rate, :paid_time, :unpaid_time, :total_amount)
        end
      end
    end

    context 'fail' do
      context 'without auth token' do
        subject do
          get '/api/v1/parking_sessions/current'
        end

        it_behaves_like 'response_401', :show_in_doc
      end

      context 'no active parking session' do
        let!(:new_user) { create(:user, :confirmed) }
        let!(:new_vehicle) { create(:vehicle, user: user) }

        subject do
          subject do
            get '/api/v1/parking_sessions/current', headers: { Authorization: get_auth_token(user) }
          end

          it_behaves_like 'response_404', :show_in_doc
        end
      end
    end
  end

  describe 'GET #show' do
    context 'success' do
      subject do
        get "/api/v1/parking_sessions/#{parking_sessions.last.id}", headers: { Authorization: get_auth_token(user) }
      end

      it_behaves_like 'response_200', :show_in_doc
    end

    context 'fail' do
      let!(:another_session) { create(:parking_session) }
      subject do
        get "/api/v1/parking_sessions/#{another_session.id}", headers: { Authorization: get_auth_token(user) }
      end

      it_behaves_like 'response_404', :show_in_doc
    end
  end

  describe 'GET #index' do
    context 'success' do
      subject do
        get '/api/v1/parking_sessions', headers: { Authorization: get_auth_token(user) }
      end

      it_behaves_like 'response_200', :show_in_doc

      it 'should contain 3 sessions' do
        subject
        expect(json.size).to eq(3)
      end
    end
  end

  describe 'GET #recent' do
    let!(:recent_sessions) { create_list(:parking_session, 5, vehicle: vehicle, status: :finished, check_out: Time.zone.now) }

    context 'success' do
      subject do
        get '/api/v1/parking_sessions/recent', headers: { Authorization: get_auth_token(user) }
      end

      it 'should contains following fields' do
        subject
        [
          :id,
          :check_in,
          :check_out,
          :lot
        ].each do |a|
          expect(json.first.with_indifferent_access.has_key?(a)).to eq(true)
        end
      end

      it_behaves_like 'response_200', :show_in_doc
    end
  end

  describe 'POST #pay' do

    let!(:current_session) { parking_sessions.last }

    subject do
      Sidekiq::Testing.fake! do
        post "/api/v1/parking_sessions/#{current_session.id}/pay", headers: { Authorization: get_auth_token(user) }
      end
    end

    it 'response wiht 201' do
      expect { subject }.to change(Payment, :count).by(1)
    end

    context 'Success' do
      let!(:valid_params) do
        {
          check_out: DateTime.current.to_i + 2.hours,
          gateway: 'cardconnect',
          set_credit_card_as_default: 1,
          gateway_params: {
            credit_card_attributes: {
              # Test card at https://developer.cardconnect.com/guides/cardpointe-gateway#first-data-north-and-rapid-connect-uat-test-card-data
              number: '4788250000121443',
              cvv: '112',
              holder_name: 'Test name',
              expiration_year: '23',
              expiration_month: '12',
              should_store: '1'
            }
          }
        }
      end

      subject do
        Sidekiq::Testing.fake! do
          post "/api/v1/parking_sessions/#{current_session.id}/pay", headers: { Authorization: get_auth_token(user) }, params: valid_params
        end
      end

      after do
        expect(Message.count).to eq(1)
        expect(Message.first.template.to_sym).to eq(:invoice)
      end

      it 'should process a succeful payment with cardconnect' do
        expect(user.default_credit_card_id).to eq(nil)
        expect { subject }.to change(Payment, :count).by(1)
        expect(Payment.last.status.to_s).to eq('success')
        expect(CreditCard.count).to eq(1)
        expect(Message.count).to eq(1)
        user.reload
        expect(user.default_credit_card_id).not_to eq(nil)
      end

      context 'without saving card' do
        let!(:valid_params) do
          {
            check_out: DateTime.current.to_i + 2.hours,
            gateway: 'cardconnect',
            set_credit_card_as_default: 1,
            gateway_params: {
              credit_card_attributes: {
                # Test card at https://developer.cardconnect.com/guides/cardpointe-gateway#first-data-north-and-rapid-connect-uat-test-card-data
                number: '4788250000121443',
                cvv: '112',
                holder_name: 'Test name',
                expiration_year: '23',
                expiration_month: '12',
                should_store: '0'
              }
            }
          }
        end

        it 'should process a succeful payment with cardconnect' do
          expect { subject }.to change(Payment, :count).by(1)
          expect(Payment.last.status.to_s).to eq('success')
          expect(CreditCard.count).to eq(0)
          user.reload
          expect(user.default_credit_card_id).to eq(nil)
        end
      end

      context 'with an card already associated to user account' do
        let!(:credit_card) { create(:credit_card, user_id: current_session.user.id) }
        let!(:valid_params) do
          {
            check_out: DateTime.current.to_i + 2.hours,
            gateway: 'cardconnect',
            gateway_params: {
              credit_card_id: credit_card.id,
              set_credit_card_as_default: 1,
              credit_card_attributes: {
                cvv: '111'
              }
            }
          }
        end

        it 'should process a succeful payment with cardconnect'do
          expect { subject }.to change(Payment, :count).by(1)
          expect(Payment.last.status.to_s).to eq('success')
          expect(CreditCard.count).to eq(1)
          user.reload
          expect(user.default_credit_card_id).to eq(credit_card.id)
        end
      end

      context 'when using Apple pay' do
        let!(:valid_params) do
          {
            check_out: DateTime.current.to_i + 2.hours,
            gateway: 'cardconnect',
            gateway_params: {
              credit_card_attributes: {
                # Test card at https://developer.cardconnect.com/guides/cardpointe-gateway#first-data-north-and-rapid-connect-uat-test-card-data
                number: '4788250000121443',
                cvv: '112',
                holder_name: 'Test name',
                expiration_year: '23',
                expiration_month: '12',
                should_store: '1'
              },
              digital_wallet_attributes: {
                encryptionhandler: 'EC_APPLE_PAY',
                devicedata: '123'
              },
              last_credit_card_digits: '1443'
            }
          }
        end

        it 'should process a succeful payment with cardconnect' do
          puts Payment.last
          puts '******************************************when using Apple pay********************************'
          # expect(Payment.last.status.to_s).to eq('success')
          # expect(Message.count).to eq(1)
          puts '******************************************Apple pay is used************************************'
        end
      end
    end

    context 'Failure' do
      after do
        expect(CreditCard.count).to eq(0)
      end

      let!(:valid_params) do
        {
          check_out: DateTime.current.to_i + 2.hours,
          gateway: 'cardconnect',
          gateway_params: {
            credit_card_attributes: {
              # Test card at https://developer.cardconnect.com/guides/cardpointe-gateway#first-data-north-and-rapid-connect-uat-test-card-data
              number: '4387751111111038',
              cvv: '112',
              holder_name: 'Test name',
              expiration_year: '23',
              expiration_month: '12',
              should_store: '1'
            }
          }
        }
      end

      subject do
        Sidekiq::Testing.fake! do
          post "/api/v1/parking_sessions/#{current_session.id}/pay", headers: { Authorization: get_auth_token(user) }, params: valid_params
        end
      end

      it 'should process failed payment with cardconnect due to number' do
        expect { subject }.to change(Payment, :count).by(1)
        expect(Payment.last.status.to_s).to eq('failed')
        expect(status).to eq(422)
      end

      context 'invalid card number format' do
        let!(:valid_params) do
          {
            check_out: DateTime.current.to_i + 2.hours,
            gateway: 'cardconnect',
            gateway_params: {
              credit_card_attributes: {
                # Test card at https://developer.cardconnect.com/guides/cardpointe-gateway#first-data-north-and-rapid-connect-uat-test-card-data
                number: '438775111111',
                cvv: '112',
                holder_name: 'Test name',
                expiration_year: '23',
                expiration_month: '12',
                should_store: '1'
              }
            }
          }
        end

        it 'should not process any payment with cardconnect due to invalid number format when tokenizing' do
          expect { subject }.to change(Payment, :count).by(0)
          expect(status).to eq(422)
        end
      end

      context 'invalid card date' do
        let!(:valid_params) do
          {
            check_out: DateTime.current.to_i + 2.hours,
            gateway: 'cardconnect',
            gateway_params: {
              credit_card_attributes: {
                # Test card at https://developer.cardconnect.com/guides/cardpointe-gateway#first-data-north-and-rapid-connect-uat-test-card-data
                number: '4387751111111038',
                cvv: '112',
                holder_name: 'Test name',
                expiration_year: '12',
                expiration_month: '12',
                should_store: '1'
              }
            }
          }
        end

        it 'should process failed payment with cardconnect due to invalid date' do
          expect { subject }.to change(Payment, :count).by(1)
          expect(Payment.last.status.to_s).to eq('failed')
          expect(status).to eq(422)
        end
      end

    end
  end
end
