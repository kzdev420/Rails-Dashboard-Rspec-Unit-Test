class ParkingAdminMailer < ApplicationMailer
  def park_expired(session)
    @session = session
    parking_lot = session.parking_lot
    @email = parking_lot.email || parking_lot.parking_admin&.email
    mail to: @email
  end

  def unrecognized_entrance(parking_lot)
    @email = parking_lot.email || parking_lot.parking_admin&.email
    mail to: @email
  end

  def unrecognized_exit(parking_lot)
    @email = parking_lot.email || parking_lot.parking_admin&.email
    mail to: @email
  end

  def voi_notification(rule_id, vehicle_id)
    @vehicle_rule = Parking::VehicleRule.find(rule_id)
    @vehicle = Vehicle.find(vehicle_id)
    @email = @vehicle_rule.lot.email || @vehicle_rule.lot.parking_admin&.email
    mail to: @email
  end
end
