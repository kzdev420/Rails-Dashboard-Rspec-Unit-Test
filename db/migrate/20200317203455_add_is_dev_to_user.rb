class AddIsDevToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :is_dev, :boolean, default: false
  end
end
