class AddColumnAdminPushNotificationTokenIdToAdminToken < ActiveRecord::Migration[5.2]
  def change
    add_reference :admin_tokens, :admin_push_notification_token, foreign_key: true
  end
end
