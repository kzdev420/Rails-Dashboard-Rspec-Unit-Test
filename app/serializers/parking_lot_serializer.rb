class ParkingLotSerializer < ApplicationSerializer
  def available
    lot_slots.select { |s| s.free? }.count
  end

  def capacity
    lot_slots.count
  end

  def rate
    object.setting&.rate&.to_f
  end

  def free
    object.setting&.free
  end

  def address
    location&.full_address
  end

  def lng
    location&.lng
  end

  def ltd
    location&.ltd
  end

  private

  def location
    @location ||= object.location
  end

  def lot_slots
    @lot_slots ||= object.parking_slots.all.to_a
  end
end
