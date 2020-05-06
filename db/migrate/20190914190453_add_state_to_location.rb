class AddStateToLocation < ActiveRecord::Migration[5.2]
  def change
    add_column :locations, :state, :string
  end
end
