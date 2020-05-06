require "administrate/field/base"

class ParkingAdminField < Administrate::Field::Base
  def to_s
    data
  end
end
