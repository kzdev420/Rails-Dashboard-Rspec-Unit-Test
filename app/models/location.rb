##
# Model to handle location data form any model in our system
# Our model using this association are: {Agency Agency model} and {ParkingLot Parking lot model}
# ## Table's Columns
# - zip => [string]
# - building => [string]
# - street => [string]
# - city => [string]
# - country => [string]
# - ltd => [float]
# - lng => [float]
# - subject_type => [string]
# - subject_id => [bigint]
# - full_address => [string] Attribute constructed before saving
# - state => [string]
# - created_at => [datetime]
# - updated_at => [datetime]
class Location < ApplicationRecord
  belongs_to :subject, polymorphic: true

  validates :lng, :ltd, :city, :state, :street, :building, :country, :zip, presence: true

  before_validation do
    self.full_address = "#{street} #{building}, #{city}, #{country}, #{zip}"
  end
end
