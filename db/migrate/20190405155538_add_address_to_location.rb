class AddAddressToLocation < ActiveRecord::Migration[5.2]
  def change
    add_column :locations, :full_address, :string
  end
end
