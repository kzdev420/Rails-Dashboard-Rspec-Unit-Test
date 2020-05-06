class AddTrackerArrayToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :trackers, :string, array: true, default: []
  end
end
