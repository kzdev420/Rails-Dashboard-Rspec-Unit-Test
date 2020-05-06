class ChangeEmailAndPlateNumberToCitext < ActiveRecord::Migration[5.2]
  def change
    change_column :users, :email, :citext
    change_column :vehicles, :plate_number, :citext
  end
end
