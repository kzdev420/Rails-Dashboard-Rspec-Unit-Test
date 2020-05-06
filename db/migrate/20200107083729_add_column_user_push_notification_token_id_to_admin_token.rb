class AddColumnUserPushNotificationTokenIdToAdminToken < ActiveRecord::Migration[5.2]
  def change
    add_reference :user_tokens, :user_push_notification_token, foreign_key: true
  end
end
