class User::Token < AuthToken
  self.table_name = 'user_tokens'
  belongs_to :user
  belongs_to :user_push_notification_token, class_name: "User::PushNotificationToken", dependent: :destroy, optional: true

  MAX_COUNT = 1
end
