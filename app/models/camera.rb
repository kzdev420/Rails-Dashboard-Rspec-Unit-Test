##
# Model to operate the system cameras, intended to be use by the {Admin admin model} on the dashboard project
# @see https://telsoft.atlassian.net/browse/PSAD-439 Camera Epic
# ## Table's Columns
# - stream => [string] URL to connect to the camera
# - login => [string] username account (if needed)
# - password => [string] password to authenticate (if needed)
# - name => [string] Name identifier
# - parking_lot_id => [bigint] ID reference to {ParkingLot parking lot model}
# - vmarkup => [json] it is a json configuration to calibrate the camera (check: PSAD-511)
# - other_information => [string] Extra data added just for information purposes
# - allowed => [boolean] Indicate if a non admin (super admin and system admin) can see the camera streaming
# - created_at => [datetime]
# - updated_at => [datetime]

class Camera < ApplicationRecord
  belongs_to :parking_lot
  attribute :stream, :uri
  attribute :password, :encrypted
  VMARKUP_KEYS = [:markup, :mvm, :ground].freeze
  store_accessor :vmarkup, *VMARKUP_KEYS
end
