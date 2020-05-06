class UserNotifier
  class << self

    def car_entrance(user, session)
      ParkingUserMailer.car_entrance(session).deliver_later
      notification = user.notifications.create(template: :car_entrance, parking_session: session)
      send_push_notification(user, notification)
    end

    def car_left(user, session)
      ParkingUserMailer.car_left(session).deliver_later
      notification = user.notifications.create(template: :car_left, parking_session: session)
      send_push_notification(user, notification)
    end

    def car_parked(user, session)
      ParkingUserMailer.car_parked(session).deliver_later
      notification = user.notifications.create(template: :car_parked, parking_session: session)
      send_push_notification(user, notification)
    end

    def car_exit(user, session)
      ParkingUserMailer.car_exit(session).deliver_later
      notification = user.notifications.create(template: :car_exit, parking_session: session)
      send_push_notification(user, notification)
    end

    def park_expired(user, session)
      ParkingUserMailer.park_expired(session).deliver_later
      notification = user.notifications.create(template: :park_expired, parking_session: session)
      send_push_notification(user, notification)
    end

    def violation_commited(user, session, email, violation_id)
      ViolationMailer.commited(email, violation_id).deliver_later
      notification = user.notifications.create(template: :violation_commited, parking_session: session)
      send_push_notification(user, notification)
    end

    def park_will_expire(user, session)
      ParkingUserMailer.park_will_expire(session).deliver_later
      notification = user.notifications.create(template: :park_will_expire, parking_session: session)
      send_push_notification(user, notification)
    end

    def session_cancelled(user, session)
      ParkingUserMailer.session_cancelled(session).deliver_later
      notification = user.notifications.create(template: :session_cancelled, parking_session: session)
      send_push_notification(user, notification)
    end

    def time_extended(user, session)
      ParkingUserMailer.time_extended(session).deliver_later
      notification = user.notifications.create(template: :time_extended, parking_session: session)
      send_push_notification(user, notification)
    end

    def send_push_notification(user, notification)
      User::PushNotificationToken.send_notification(user, notification)
    end
  end
end
