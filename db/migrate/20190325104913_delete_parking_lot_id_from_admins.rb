class DeleteParkingLotIdFromAdmins < ActiveRecord::Migration[5.2]
  def up
    remove_reference :admins, :parking_lot, index: true
  end

  def down
    add_reference :admins, :parking_lot, index: true
  end
end
