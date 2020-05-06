class RenameChargeColumnOnParkingSetting < ActiveRecord::Migration[5.2]
  def change
    rename_column :parking_settings, :charge, :period
  end
end
