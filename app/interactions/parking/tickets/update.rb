module Parking
  module Tickets
    class Update < ApplicationInteraction
      string :status, default: nil
      string :remark, default: nil
      interface :photo_resolution, default: nil # can be File or String
      integer :admin_id, default: nil
      object :object, class: Ticket

      def execute
        Ticket.transaction do
          if object.status != status && remark.blank?
            errors.add(:remark, :empty)
            raise ActiveRecord::Rollback
          end
          update_ticket
          create_log
        end
      end

      private

      def update_ticket
        transactional_update!(object, ticket_params)
        transactional_update!(object.violation.vehicle_rule, status: status == "resolved" ? :archived : :active)
      end

      def ticket_params
        data = inputs.slice(:status, :admin_id)
        data[:photo_resolution] = { data: inputs[:photo_resolution] } if inputs[:photo_resolution].present?
        data
      end

      def create_log
        object.paper_trail_options[:only].each do |key|
          if object.saved_changes[key].present?
            from, to = object.saved_changes[key]
            TicketMailer.ticket_changed(object.id, key, from, to).deliver_later if object.admin_id
            object.reload.logs.first.update(comment: inputs[:remark]) if key.to_sym == :status
          end
        end
      end
    end
  end
end
