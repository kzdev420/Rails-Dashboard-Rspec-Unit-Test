class AddParkingLotToAdmins < ActiveRecord::Migration[5.2]
  def change
    add_reference :admins, :parking_lot, index: true
  end
end
