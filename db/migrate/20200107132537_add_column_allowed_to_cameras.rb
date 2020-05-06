class AddColumnAllowedToCameras < ActiveRecord::Migration[5.2]
  def change
    add_column :cameras, :allowed, :boolean, default: true
  end
end
