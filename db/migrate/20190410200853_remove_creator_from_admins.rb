class RemoveCreatorFromAdmins < ActiveRecord::Migration[5.2]
  def up
    remove_reference :admins, :creator, index: true
  end

  def down
    add_reference :admins, :creator, index: true
  end
end
