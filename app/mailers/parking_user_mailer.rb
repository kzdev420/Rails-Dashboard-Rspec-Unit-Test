class ParkingUserMailer < ApplicationMailer

  %w(
    park_expired park_will_expire car_entrance car_parked
    car_left car_exit session_cancelled time_extended
  ).each do |operation|
    define_method operation do |session|
      set_variables(session)
      mail(
        to: @email,
        subject: I18n.t("parking_user_mailer.#{operation}.subject", { plate_number: session.vehicle&.plate_number })
      )
    end
  end

  private

  def set_variables(session)
    @email = session.vehicle.user.email
    @first_name = session.vehicle.user.first_name
    @session = session
    @parking_lot = session.parking_lot
    @plate_number = session.vehicle.plate_number
  end
end
