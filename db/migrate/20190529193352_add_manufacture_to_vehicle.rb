class AddManufactureToVehicle < ActiveRecord::Migration[5.2]
  def change
    add_column :vehicles, :manufacture, :string
  end
end
