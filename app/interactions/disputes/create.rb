module Disputes
  class Create < ApplicationInteraction
    attr_reader :object

    string :text
    string :reason
    integer :parking_session_id
    integer :user_id

    def execute
      Dispute.transaction do
        create_dispute
        create_message
        resolve_alerts
        send_notification
      end
    end

    private

    def resolve_alerts
      object.parking_session.alerts.each do |alert|
        transactional_update!(alert, status: :resolved)
      end
    end

    def create_dispute
      admin = Admin.joins(parking_lots: :parking_sessions).where(parking_sessions: { id: parking_session_id }).first
      @object = transactional_create!(Dispute, inputs.except(:text).merge(admin: admin))
    end

    def create_message
      transactional_create!(Message, subject: object, author: object.user, to: object.admin, text: text, template: :dispute)
    end

    def send_notification
      AdminMailer.assigned_to_dispute(object.id, object.admin_id)
    end
  end
end
