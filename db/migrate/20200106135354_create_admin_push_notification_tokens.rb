class CreateAdminPushNotificationTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_push_notification_tokens do |t|
      t.string :value

      t.timestamps
    end
  end
end
