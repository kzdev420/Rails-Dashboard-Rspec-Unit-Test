##
# Model to handle token associated to an {Admin admin} instance
# ## Table's Columns
# - value => [string] Token value
# - expired_at => [datetime] When the token expires
# - admin_id => [integer] ID reference to {Admin admin model}
# - admin_push_notification_token_id => [bigint] ID reference to {Admin::PushNotificationToken Admin::PushNotificationToken}
# - created_at => [datetime]
# - updated_at => [datetime]
class Admin::Token < AuthToken
  self.table_name = 'admin_tokens'
  belongs_to :admin
  belongs_to :admin_push_notification_token, class_name: "Admin::PushNotificationToken", dependent: :destroy, optional: true

  ##
  # Max amount of tokens that can be associated to an {Admin admin} instance
  MAX_COUNT = 3
end
