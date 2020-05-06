##
# Model to handle each parking lot on the system.
# ## Table's Columns
# - email => [string] Email to whom the system will reach on every event that occurs on the parking lot
# - name => [string] Name tag for the parking lot
# - phone => [string] Contact number
# - time_zone => [string] Time zone where the parking lot is
# - avatar => [string] Profile photo
# - status => [integer] active or suspended
# - outline => [json] JSON attribute with coordinates point to handle parking lot drawing on the Kiosk app.
#                     For more information see {https://telsoft.atlassian.net/browse/PSAD-491 PSAD-491}
# - created_at => [datetime]
# - updated_at => [datetime]
class ParkingLot < ApplicationRecord
  include ActiveStorageSupport::SupportForBase64

  with_options dependent: :destroy do |assoc|
    assoc.has_many :parking_slots

    assoc.with_options foreign_key: :lot_id do |inner_assoc|
      inner_assoc.has_many :rules, class_name: 'Parking::Rule'
      inner_assoc.has_many :zones, class_name: 'Parking::Zone'
      inner_assoc.has_many :vehicle_rules, class_name: 'Parking::VehicleRule'
    end

    assoc.has_many :kiosks
    assoc.has_many :rights, class_name: 'Admin::Right', as: :subject
    assoc.has_many :cameras
    assoc.has_many :parking_sessions
    assoc.has_many :places
    assoc.has_one :setting, class_name: 'Parking::Setting', as: :subject
    assoc.has_one :location, as: :subject
  end

  has_many :violations, through: :parking_sessions
  has_many :disputes, through: :parking_sessions
  has_many :admins, through: :rights
  has_many :parking_admins, -> { parking_admin.where(status: :active) }, class_name: 'Admin', through: :rights, source: :admin
  has_many :town_managers, -> { town_manager.where(status: :active) }, class_name: 'Admin', through: :rights, source: :admin

  has_many :parking_plans, class_name: "Image", as: :imageable

  validates_format_of :email, with: Devise.email_regexp, if: -> { email.present? }
  validates :phone, phony_plausible: true

  enum status: { active: 0, suspended: 1 }
  OUTLINE_KEYS = [:kiosks_positions, :labels, :points, :lines, :spaces, :exits].freeze # Keys on the outline file
  store_accessor :outline, *OUTLINE_KEYS

  has_one_base64_attached :avatar

  accepts_nested_attributes_for :location, :setting

  delegate :period, :rate, :overtime, :parked, :free, to: :setting
  delegate :full_address, to: :location
  alias :address :full_address

  validates :town_managers, :name, presence: true

  PLACES_MAX_COUNT = 20 # Max amount of {Place places model} that each parking lot can have

  ParkingLot::PERIOD_NORMALIZER = 3600 # Variable to indicate the standard time for the parking lot price

  # It indicates the amount that will be charge by hours
  # @return Float
  def calc_fee_by_hours(hours)
    if hours
      rate * hours.to_i
    end
  end

  # @return {Admin Admin} with parking_admin role associated to the parking lot
  def parking_admin
    parking_admins.first
  end

  # @return {Admin Admin} with town_manager role associated to the parking lot
  def town_manager
    town_managers.first
  end

  def parking_admin=(admin)
    # TODO: remove later
  end

  def town_manager=(admin)
    # TODO: remove later
  end

end
