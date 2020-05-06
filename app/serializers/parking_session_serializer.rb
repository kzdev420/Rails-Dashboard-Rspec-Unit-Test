class ParkingSessionSerializer < ApplicationSerializer
  attributes :status,
             :ai_status,
             :entered_at,
             :parked_at,
             :left_at,
             :exit_at,
             :paid_time,
             :unpaid_time

  [:entered_at, :exit_at, :parked_at, :left_at].each do |attr|
    define_method(attr) { utc(object.send(attr)) }
  end

  def check_in
    utc(object.check_in)
  end

  def check_out
    utc(object.check_out)
  end

  def created_at
    utc(object.created_at)
  end

  def plate_number
    object.vehicle.plate_number
  end

  def paid_time
    payment_info.paid
  end

  def unpaid_time
    payment_info.unpaid
  end

  private

  def payment_info
    @payment_info ||= object.payment_info
  end

  def seconds
    if object.check_in && object.check_out
      object.check_out.to_i - object.check_in.to_i
    end
  end

  def vehicle
    @vehicle ||= object.vehicle
  end

  def parking_slot
    @parking_slot ||= object.parking_slot
  end

  def parking_lot
    @parking_lot ||= parking_slot&.parking_lot
  end
end
