class User::Notification < ApplicationRecord
  belongs_to :user
  belongs_to :parking_session
  enum status: { unread: 0, read: 1 }
  enum template: {
    car_entrance: 0, # Car entered a parking lot
    car_parked: 1, # Car parked on a parking space
    car_exit: 2, # Car exits the parking lot
    car_left: 3,  # Car leaves the parking space
    session_cancelled: 15, # Session was cancelled by the user (left parking space)
    success_payment: 4, # User paid successfully
    park_started: 5, # Parking time started
    park_will_expire: 6, # Parking time is about to expire
    park_expired: 7, # Parking time expired
    payment_reminder: 8, # Payment reminder for extending parking time
    violation_commited: 9, # Violation committed
    violation_received: 10, # Violation ticket received
    violation_resolved: 11,  # Violation ticket resolved,
    car_switched: 12, # Car switched parking space
    vehicle_of_interest: 13, # Vehicle of Interest enters the parking lot
    vehicle_becomes_interest: 14, # Car becomes a vehicle of interest
    payment_failure: 15, # An error happened when user paid
    time_extended: 16 # When user extended time
  } # https://telsoft.atlassian.net/browse/PSAD-227

  before_validation do
    if !title && template
      locales_key_title = "activerecord.models.user/notification.templates.#{template}_title"
      locales_key_text = "activerecord.models.user/notification.templates.#{template}_text"
      self.title = I18n.t(locales_key_title) if I18n.exists?(locales_key_title)
      self.text = I18n.t(locales_key_text, { plate_number: parking_session.vehicle.plate_number }) if I18n.exists?(locales_key_text)
    end
  end
end
