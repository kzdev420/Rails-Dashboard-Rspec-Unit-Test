##
# Model to handle each parking slot belong to a {ParkingLot parking lot}
# ## Table's Columns
# - name => [string] Slot name, mostly refer as parking slot id from the AI and Kiosk app
# - status => [integer] Indicate if the parking slot is occupied or free, This is set on car_parked.rb or car_left.rb
# - archived => [boolean] if the parking slot was store to not be used (It's not currelty used)
# - parking_zone_id => [bigint] Reference ID to a {Parking::Zone parking zone}
# - parking_lot_id => [integer] Reference ID to a {ParkingLot parking lot}
# - created_at => [datetime]
# - updated_at => [datetime]

class ParkingSlot < ApplicationRecord
  belongs_to :parking_lot
  belongs_to :zone, class_name: 'Parking::Zone', optional: true
  has_many :parking_sessions, dependent: :nullify
  has_one :coordinate_parking_plan

  scope :active, -> { where(archived: false) }
  default_scope { active }

  enum status: [:free, :occupied]

  validates_uniqueness_of :name, scope: :parking_lot_id

  validates :name, presence: true

  def archived!
    update(archived: true)
  end

  def self.name_with_prefix(name)
    name.split('-')
  end
end
