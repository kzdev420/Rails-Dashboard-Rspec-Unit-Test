class ManufacturerSerializer < ApplicationSerializer
  attributes :id, :name

  def name
    object.name.capitalize
  end

end
