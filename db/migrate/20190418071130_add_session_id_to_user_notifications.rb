class AddSessionIdToUserNotifications < ActiveRecord::Migration[5.2]
  def change
    add_reference :user_notifications, :parking_session, foreign_key: true
  end
end
