##
# Model to handle the following settings on each parking lot:
# - rate - Rate by ParkingLot::PERIOD_NORMALIZER (check {ParkingLot parking lot model} for more information)
# - parked - Time before car considered as parked (minutes)
# - overtime - Overtime allowed (seconds)
# - period - Minimum chargeble time (seconds)
# - free - Seconds that user can stay without paying
class Parking::Setting < ApplicationRecord
  belongs_to :subject, polymorphic: true
end
