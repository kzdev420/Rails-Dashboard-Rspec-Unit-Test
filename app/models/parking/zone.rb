#
# Sometimes the {ParkingLot parking lot} can be devided in sections/zones, and this zone contains certain {ParkingSlot parking slots}
# - name => [string] Zone's name to identified it, an example can be Zone 1, Zone 2...
# - lot_id => [integer] Reference ID to a {ParkingLot parking lot}
# - created_at => [datetime]
# - updated_at => [datetime]
# @note This model has not used on the system when this was written (02-14-20)
class Parking::Zone < ApplicationRecord
  has_one :setting, as: :subject
  belongs_to :lot, class_name: 'ParkingLot'
  delegate :period, :rate, :overtime, :parked, :free, to: :setting
end
