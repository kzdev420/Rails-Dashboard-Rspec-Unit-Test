require "administrate/field/base"

class JsonFileField < Administrate::Field::Base
  def to_s
    data
  end
end
