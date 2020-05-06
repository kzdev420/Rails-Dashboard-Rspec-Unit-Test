class AddFeeAppliedToParkingSession < ActiveRecord::Migration[5.2]
  def change
    add_column :parking_sessions, :fee_applied, :float
  end
end
