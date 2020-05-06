##
# Model to store vehicle associatied to a violation. This is created on violation_commited.rb
# ## Table's Columns
# - color => [string] Color store in case there was not vehicle created
# - vehicle_type => [string]  Vehicle Type store in case there was not vehicle created
# - status => [integer] Indicate if the violation won't be show anymore
# - vehicle_id => [bigint] Reference ID to a {Vehicle vehicle}
# - lot_id => [bigint]  Reference ID to a {ParkingLot parking lot}
# - created_at => [datetime]
# - updated_at => [datetime]
class Parking::VehicleRule < ApplicationRecord
  belongs_to :vehicle, optional: true
  belongs_to :lot, class_name: 'ParkingLot'
  has_one :violation, class_name: "Parking::Violation", foreign_key: :parking_vehicle_rules_id
  enum status: [:active, :archived]
  validates_uniqueness_of :vehicle_id, scope: %i[lot_id]

end
