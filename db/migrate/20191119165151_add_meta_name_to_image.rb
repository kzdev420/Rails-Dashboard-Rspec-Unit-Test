class AddMetaNameToImage < ActiveRecord::Migration[5.2]
  def change
    add_column :images, :meta_name, :string
  end
end
