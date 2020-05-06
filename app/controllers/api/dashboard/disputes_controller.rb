module Api
  module Dashboard
    class DisputesController < ApplicationController
      api :GET, '/api/dashboard/disputes', 'Disputes list'
      header :Authorization, 'Auth token from users#sign_in', required: true
      param :status, String, 'Status of dispute'
      param :parking_lot_id, Integer, 'Parking lot id'
      param :admin_id, Integer, 'Admin id (Dispute resolver)'

      def index
        scope = DisputesIndexQuery.call(params.merge(user: current_user))
        respond_with paginate(scope), each_serializer: DisputeSerializer
      end

      api :GET, '/api/dashboard/disputes/:id', 'Dispute details'
      header :Authorization, 'Auth token from users#sign_in', required: true

      def show
        dispute = Dispute.find(params[:id])
        authorize! dispute
        respond_with dispute, serializer: DisputeShowSerializer
      end
    end
  end
end
