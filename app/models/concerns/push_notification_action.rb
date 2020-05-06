#
# File concern to send push notifications
module PushNotificationAction
  extend ActiveSupport::Concern

  included do
    # @return [Hash]
    def self.send_notification(user, notification)
      registration_ids = user.tokens.map(&:user_push_notification_token).uniq.compact # an array of one or more client registration tokens
      return if registration_ids.empty?
      options = {
        "data": {
          "id": notification.id,
          "type": notification.template,
          "session_id": notification.parking_session_id,
          "alert_id": notification.parking_session.alerts.where(status: :opened).last&.id
        },
        "notification": {
          "title": notification.title,
          "body": notification.text
        }
      }

      response = $fcm.send(registration_ids.map(&:value), options)
    end

    def self.send_message(user, message)
      registration_ids = user.tokens.map(&:user_push_notification_token).uniq.compact # an array of one or more client registration tokens
      return if registration_ids.empty?
      options = {
        "data": {
          "id": message.id,
          "type": 'message'
        },
        "notification": {
          "title": message.title,
          "body": message.text
        }
      }

      response = $fcm.send(registration_ids.map(&:value), options)
    end
  end
end
