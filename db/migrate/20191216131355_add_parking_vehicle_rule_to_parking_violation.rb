class AddParkingVehicleRuleToParkingViolation < ActiveRecord::Migration[5.2]
  def change
    add_reference :parking_violations, :parking_vehicle_rules, foreign_key: true
  end
end
