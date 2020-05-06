##
# Model to indicate nearby places to a {ParkingLot parking lot}
# ## Table's Columns
# - parking_lot_id => [integer] Reference to a {ParkingLot parking lot}
# - name => [string] Name of the place
# - category => [integer] Which category belongs
# - distance => [float] Distance in meter from the {ParkingLot parking lot}
# - created_at => [datetime]
# - updated_at => [datetime]
class Place < ApplicationRecord
  belongs_to :parking_lot
  validates :name, presence: true, length: { minimum: 2, maximum: 25 }
  validates :distance, presence: true

  enum category: {
    gas_station: 0,
    charging_outlet: 1,
    park_bench: 2,
    mall: 3,
    hotel: 4
  }
end
