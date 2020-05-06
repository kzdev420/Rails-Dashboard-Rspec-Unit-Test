module Api
  module Dashboard
    class Parking::TicketsController < ::Api::Dashboard::ApplicationController
      wrap_parameters :parking_ticket

      api :GET, '/api/dashboard/parking/tickets', 'Parking tickets list'
      header :Authorization, 'Auth token', required: true
      param :per_page, Integer,
            'Items per page count, default is 10. Check response headers for total count (key: X-Total)',
            required: false
      param :page, Integer, 'Items page number'
      param :type, ::Parking::Rule.names.keys, desc: 'Parking rule name'
      param :query, String, 'Parking lot name'
      param :range, Hash, 'Date Range (all violations committed within the selected range)' do
        param :from, Integer, 'From date in timestamp (numeric) format', required: true
        param :to, Integer, 'To date in timestamp (numeric) format', required: true
      end
      param :agency_id, Integer, 'Assigned Agency'
      param :admin_id, Integer, 'Assigned Officer'
      param :parking_lot_id, Integer, 'Parking lot id'
      param :status, String, 'Ticket status'

      def index
        scope = paginate TicketsIndexQuery.call(params.merge(user: current_user))
        respond_with scope, each_serializer: Parking::TicketSerializer
      end

      api :PUT, '/api/dashboard/parking/tickets/:id', 'Parking ticket update'
      header :Authorization, 'Auth token', required: true
      param :parking_ticket, Hash, required: true do
        param :admin_id, Integer, 'Admin id'
        param :status, ::Parking::Ticket.statuses.keys, 'Ticket status'
      end

      def update
        ticket = ::Parking::Ticket.find(params[:id])
        authorize! ticket
        payload = params.fetch(:parking_ticket, {}).merge(object: ticket)
        result = ::Parking::Tickets::Update.run(payload)
        respond_with result, serializer: Parking::DetailedTicketSerializer
      end

      api :GET, "/api/dashboard/parking/tickets/:id", 'Get ticket by ID'
      param :id, Integer, 'Ticket id', required: true
      header :Authorization, 'Auth token', required: true

      def show
        ticket = ::Parking::Ticket.find(params[:id])
        authorize! ticket
        respond_with ticket, serializer: Parking::DetailedTicketSerializer
      end

    end
  end
end
