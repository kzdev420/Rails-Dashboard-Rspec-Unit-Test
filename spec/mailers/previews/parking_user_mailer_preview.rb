class ParkingUserMailerPreview < ActionMailer::Preview

  # Accessible from http://localhost:3000/rails/mailers/parking_user_mailer/park_expired
  def park_expired
    ParkingUserMailer.park_expired(current_session)
  end

  # Accessible from http://localhost:3000/rails/mailers/parking_user_mailer/park_will_expire
  def park_will_expire
    ParkingUserMailer.park_will_expire(current_session)
  end

  # Accessible from http://localhost:3000/rails/mailers/parking_user_mailer/car_entrance
  def car_entrance
    ParkingUserMailer.car_entrance(current_session)
  end

  # Accessible from http://localhost:3000/rails/mailers/parking_user_mailer/car_exit
  def car_exit
    ParkingUserMailer.car_exit(current_session)
  end

  # Accessible from http://localhost:3000/rails/mailers/parking_user_mailer/car_parked
  def car_parked
    ParkingUserMailer.car_parked(current_session)
  end

  # Accessible from http://localhost:3000/rails/mailers/parking_user_mailer/car_left
  def car_left
    ParkingUserMailer.car_left(current_session)
  end

  private

  def current_session
    parking_lot = ParkingLot.new(
      email: 'parkinglot@admin.com',
      name: 'Parking Lot Easton',
      location: Location.new(
        country: Faker::Address.country,
        city: Faker::Address.city,
        building: Faker::Address.building_number,
        street: Faker::Address.street_name,
        state: Faker::Address.state,
        ltd: Faker::Address.latitude.to_f,
        lng: Faker::Address.longitude.to_f,
        zip: Faker::Address.zip(Faker::Address.state_abbr)
      ),
      setting: Parking::Setting.new(
        rate: 1.0,
        parked: 40.minutes.to_i,
        overtime: 30.minutes.to_i,
        period: 30.minutes.to_i,
        free: 10.minutes.to_i
      )
    )
    session = ParkingSession.new(
      id: 1,
      check_out: 1.hour.from_now,
      parked_at: DateTime.now,
      vehicle: Vehicle.new(
        plate_number: 'ABC-1234',
        user: User.new(
          email: 'test@test.com',
          first_name: 'John'
        )
      ),
      parking_lot: parking_lot,
      parking_slot: ParkingSlot.new(
        name: '42',
        parking_lot: parking_lot
      )
    )
  end
end
