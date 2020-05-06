class MoveContactPersonToString < ActiveRecord::Migration[5.2]
  def up
    remove_reference :agencies, :contact_person, index: true
    add_column :agencies, :phone, :string
  end

  def down
    add_reference :agencies, :contact_person, index: true
    remove_column :agencies, :phone, :string
  end
end
