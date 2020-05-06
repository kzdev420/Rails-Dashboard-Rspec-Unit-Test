class AddColumnManufacturerToVehicles < ActiveRecord::Migration[5.2]
  def change
    add_reference :vehicles, :manufacturer, foreign_key: true
    remove_column :vehicles, :manufacture
  end
end
