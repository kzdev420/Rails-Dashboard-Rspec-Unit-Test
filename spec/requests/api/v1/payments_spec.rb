require 'rails_helper'

RSpec.describe Api::V1::VehiclesController, type: :request do
  let!(:user) { create(:user, :confirmed) }
  let!(:vehicle) { create(:vehicle, user: user) }
  let!(:parking_sessions) { create_list(:parking_session, 19, vehicle: vehicle) }
  let!(:payments) { parking_sessions.each { |ps| create(:payment, parking_session: ps) } }
  let(:params_options) {}

  describe 'GET #index' do
    context 'success' do
      subject do
        get "/api/v1/payments", headers: { Authorization: get_auth_token(user) }, params: params_options
      end

      it_behaves_like 'response_200', :show_in_doc

      context 'First page' do
        it 'It should contain 10 elements' do
          subject
          expect(json.size).to eq(10)
        end
      end

      context 'Second page' do
        let(:params_options) { { page: 2 } }

        ##
        # As 19 parking_sessions were created, the second page should return 9 payment elements

        it 'It should contain 9 elements' do
          subject
          expect(json.size).to eq(9)
        end
      end

      it 'should contains following fields' do
        subject
        json.each do |payment|
          [
            "amount",
            "status",
            "created_at",
            "parking_session_id",
            "parking_lot"
          ].each do |a|
            expect(payment.has_key?(a)).to eq(true)
          end
        end
      end

      context 'With parking lot ids filter' do
        let!(:parking_lot) { create(:parking_lot) }
        let!(:parking_sessions_lot_2) { create_list(:parking_session, 2, parking_lot_id: parking_lot.id, vehicle: vehicle) }
        let(:params_options) { {  parking_lot_ids: [parking_lot.id] } }
        let!(:payments_lot_2) { parking_sessions_lot_2.each { |ps| create(:payment, parking_session: ps) } }

        it "should show only payment on one parking lot" do
          expect(Payment.count).to eq(21)
          subject
          expect(json.size).to eq(2)
        end
      end

      context 'With statuses filter' do
        context 'With success' do
          let(:params_options) { {  statuses: [:success], per_page: 100 } }

          it "should show only payment with success" do
            subject
            expect(json.size).to eq(Payment.success.count)
          end
        end

        context 'With failed and success' do
          let(:params_options) { {  statuses: [:success, :failed], per_page: 100 } }

          it "should show only payment with success" do
            subject
            expect(json.size).to eq(Payment.success.count + Payment.failed.count)
          end
        end
      end

      context 'With date range' do
        context 'only with FROM key' do
          let!(:parking_sessions_future) { create_list(:parking_session, 2, vehicle: vehicle) }
          let!(:payments_future) { parking_sessions_future.each { |ps| create(:payment, parking_session: ps, created_at: DateTime.now + 2.days) } }
          let(:params_options) { {  range: { from: DateTime.now + 2.days }  } }

          it "should show only payment made on #{DateTime.now + 2.days}" do
            expect(Payment.count).to eq(21)
            subject
            expect(json.size).to eq(2)
          end
        end

        context 'with FROM and TO keys' do
          let!(:parking_sessions_2_days) { create_list(:parking_session, 2, vehicle: vehicle) }
          let!(:payments_in_2_days) { parking_sessions_2_days.each { |ps| create(:payment, parking_session: ps, created_at: DateTime.now + 2.days) } }
          let!(:parking_sessions_1_day) { create_list(:parking_session, 2, vehicle: vehicle) }
          let!(:payments_in_1_day) { parking_sessions_1_day.each { |ps| create(:payment, parking_session: ps, created_at: DateTime.now + 1.days) } }
          let(:params_options) { {  range: { from: DateTime.now + 1.days, to: DateTime.now + 2.days }  } }

          it "should show only payment made from #{DateTime.now + 1.days} to #{DateTime.now + 2.days}" do
            expect(Payment.count).to eq(23)
            subject
            expect(json.size).to eq(4)
          end
        end

      end

    end
  end
end