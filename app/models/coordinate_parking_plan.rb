##
# Model to store a coordinate on top of a parking plan ({Image image model} associated on {ParkingLot parking lot})
# @see https://dashboard.telesoftmobile.com/dashboard/parking_lots/1/spaces Parking Space section on dashboard project
class CoordinateParkingPlan < ApplicationRecord
  belongs_to :parking_slot
  belongs_to :image
end
