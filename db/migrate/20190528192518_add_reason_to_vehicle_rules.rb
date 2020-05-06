class AddReasonToVehicleRules < ActiveRecord::Migration[5.2]
  def change
    add_column :parking_vehicle_rules, :reason, :integer
  end
end
