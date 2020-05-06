class CreateUserPushNotificationTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :user_push_notification_tokens do |t|
      t.string :value

      t.timestamps
    end
  end
end
