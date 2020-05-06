require "administrate/field/base"

class TownManagerField < Administrate::Field::Base
  def to_s
    data
  end
end
