module Api
  module Dashboard
    module Parking
      class TicketPolicy < ApplicationPolicy
        def update?
          user.admin? || agency_manager? || officer_ticket?
        end

        def show?
          user.admin? || agency_manager? || officer_ticket?
        end

        private

        def agency_manager?
          ::Parking::Ticket.joins(agency: :managers).where(admins: { id: user.id }).exists? if user.manager?
        end

        def officer_ticket?
          record.admin_id == user.id if user.officer?
        end
      end
    end
  end
end
