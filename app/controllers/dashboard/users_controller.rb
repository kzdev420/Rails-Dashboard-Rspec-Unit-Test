module Dashboard
  class UsersController < AdministrateController
    include ActionView::Helpers::AssetUrlHelper

    def notifications_and_messages
      user = User.find(params[:id])
      # Notifications
      session = user.parking_sessions.last

      if session.nil?
        flash[:alert] = 'This account needs at least a parking session before creating notifications, please contact a developer'
        redirect_to dashboard_user_path(user)
        return
      end

      2.times do
        [:car_parked, :car_entrance, :car_left, :car_exit].each do |template|
          user.notifications.create!(template: template, parking_session: session, text: Faker::Lorem.sentence, status: :read)
        end
      end
      2.times do
        [:car_parked, :car_entrance, :car_left, :car_exit].each do |template|
          user.notifications.create!(template: template, parking_session: session, text: Faker::Lorem.sentence)
        end
      end
      #Messages
      [:invoice, :violation, :promotion].each do |template|
        user.messages.create!(subject: Dispute.all.sample, template: template, text: Faker::Lorem.sentence, author: Admin.first, to: user)
      end
      [:invoice, :violation, :promotion].each do |template|
        user.messages.create!(subject: Dispute.all.sample, template: template, text: Faker::Lorem.sentence, author: Admin.first, to: user, read: true)
      end
      redirect_to dashboard_user_path(user)
    end

    def message_push_notifications
      user = User.find(params[:id])
      message = user.messages.create!(template: :violation, text: Faker::Lorem.sentence, to: user)
      send_message_push_notification(user, message)
      redirect_to dashboard_user_path(user)
    end

    def notification_push_notifications
      user = User.find(params[:id])
      session = user.parking_sessions.last
      notification = user.notifications.create!(template: :car_parked, parking_session: session, text: Faker::Lorem.sentence)
      send_notification_push_notification(user, notification)
      redirect_to dashboard_user_path(user)
    end

    def update
      user = User.find(params[:id])
      ::Users::UpdateSettings.run(params.fetch(:user, {}).merge(user: user))
      redirect_to dashboard_user_path(user)
    end

    private

    def send_notification_push_notification(user, notification)
      User::PushNotificationToken.send_notification(user, notification)
    end

    def send_message_push_notification(user, message)
      User::PushNotificationToken.send_message(user, message)
    end
  end
end
