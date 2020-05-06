module Api
    module V1
      class PaymentsController <  Api::V1::ApplicationController
        # before_action :authenticate_user!

        api :GET, '/api/v1/payments', 'Get user transaction history'
        param :per_page, Integer, 'Items per page, default is 10. Check response headers for total count (key: X-Total)', required: false
        param :parking_lot_ids, Array, of: Integer, required: false
        param :range, Hash, 'Date Range (all payments within the selected range)' do
          param :from, Integer, 'Date with following format: Year-Month-Day, Example: 2020-01-31', required: true
          param :to, Integer, 'Date with following format: Year-Month-Day, Example: 2020-01-31', required: true
        end
        param :statuses, Array, of: Payment.statuses.keys, required: false
        header :Authorization, 'Auth token from users#sign_in', required: true

        def index
          respond_with paginate(Api::V1::PaymentsQuery.call(params.merge(current_user: current_user))), each_serializer: PaymentSerializer
        end

      end
    end
end