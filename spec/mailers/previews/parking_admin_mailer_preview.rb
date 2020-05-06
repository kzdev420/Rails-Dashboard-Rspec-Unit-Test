class ParkingAdminMailerPreview < ActionMailer::Preview

  # Accessible from http://localhost:3000/rails/mailers/parking_admin_mailer/park_expired
  def park_expired
    ParkingAdminMailer.park_expired(current_session)
  end

  # Accessible from http://localhost:3000/rails/mailers/parking_admin_mailer/unrecognized_entrance
  def unrecognized_entrance
    ParkingAdminMailer.unrecognized_entrance(parking_lot)
  end

  # Accessible from http://localhost:3000/rails/mailers/parking_admin_mailer/unrecognized_exit
  def unrecognized_exit
    ParkingAdminMailer.unrecognized_exit(parking_lot)
  end

  private

  def parking_lot
    ParkingLot.new(
      email: 'test@test.com'
    )
  end

  def current_session
    session = ParkingSession.new(
      id: 1,
      check_out: 1.hour.from_now,
      vehicle: Vehicle.new(
        plate_number: 'ABC-1234',
        user: User.new(
          email: 'test@test.com'
        )
      ),
      parking_lot: ParkingLot.new(
        email: 'parkinglot@admin.com',
        setting: Parking::Setting.new(
          rate: 1.0,
          parked: 30.minutes.to_i,
          overtime: 30.minutes.to_i,
          period: 30.minutes.to_i,
          free: 10.minutes.to_i
        )
      )
    )
  end
end
