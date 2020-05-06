class AddTrackersToAdmins < ActiveRecord::Migration[5.2]
  def change
    add_column :admins, :trackers, :string, array: true, default: []
  end
end
