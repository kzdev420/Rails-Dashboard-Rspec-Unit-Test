class DeleteReasonFromParkingVehicleRule < ActiveRecord::Migration[5.2]
  def change
    remove_column :parking_vehicle_rules, :reason
  end
end
