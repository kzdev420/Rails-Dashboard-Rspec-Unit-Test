#
# Model to handle Vehicles, this vehicle can be created by the {User user} itself
# or can be created by the AI by triggering one's of the files at app/interactions/parking_sessions/
# ## Table's Columns
# - plate_number => [string] Indicates the plate number type by the User or the one identified by the AI
# - vehicle_type => [string] Indicates the type of the vehicle
# - color => [string]  Indicates the color of the vehicle
# - model => [string] Indicates the model of the vehicle
# - user_id => [bigint] Reference ID to the {User user} owner
# - status => [integer] Indicate if the user 'deleted' the vehicle from the system, because we actually don't remove it
# - created_at => [datetime]
# - updated_at => [datetime]
class Vehicle < ApplicationRecord
  include ActiveStorageSupport::SupportForBase64

  has_many :parking_sessions, dependent: :nullify

  with_options dependent: :destroy do |assoc|
    assoc.has_many :rules, class_name: 'Parking::VehicleRule'
  end

  has_many_base64_attached :images

  belongs_to :user, optional: true
  belongs_to :manufacturer, optional: true
  validates_uniqueness_of :plate_number, allow_blank: true, allow_nil: true
  enum status: { active: 0, deleted: 1 }

  before_validation do
    if plate_number&.downcase == 'null'
      self.plate_number = nil
    else
      self.plate_number = plate_number&.downcase
    end

  end

  def recognized?
    plate_number.present?
  end

end
