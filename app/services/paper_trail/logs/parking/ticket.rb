module PaperTrail
  module Logs
    module Parking
      class Ticket
        attr_writer :status

        def generate_logs(ticket)
          trails = []
          ticket.logs.includes([:item]).each do |log|
            log.changeset.each do |attr, values|
              trails.push({
                type_of_change: I18n.t("logs.parking/ticket.type_of_change.#{attr}"),
                old_value: send(attr, values.first) || 'No value',
                new_value: send(attr, values.last) || 'No value',
                performed_by: log.whodunnit.present? ? Admin.find_by(id: log.whodunnit).email : 'N/A',
                updated_at: log.created_at.to_i,
                remark: attr.to_sym == :status ? log.comment : 'N/A'
              })
            end
            trails.push(creation_log(log)) if log.event == 'create'
          end
          trails
        end

        private

        def admin_id(id)
          admin = Admin.find_by(id: id)
          admin.present? ? admin.username : I18n.t("logs.parking/ticket.admin_id_nil")
        end

        def status(status)
          status
        end

        def creation_log(log)
          {
            type_of_change: I18n.t('logs.parking/ticket.type_of_change.creation'),
            old_value: 'N/A',
            new_value: 'N/A',
            performed_by: 'N/A',
            updated_at: log.created_at.to_i,
            remark: 'N/A'
          }
        end
      end
    end
  end
end
