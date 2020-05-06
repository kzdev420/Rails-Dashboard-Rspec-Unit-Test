module Parking::Rules
  class Create < ApplicationInteraction
    include CreateWithObject

    string :name
    string :description, default: nil
    array :admins, default: []
    integer :agency_id, default: nil
    integer :lot_id
    boolean :status

    def execute
      simple_create(Parking::Rule)
    end
  end
end
