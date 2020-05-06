class AddColumnOtherInformationToCameras < ActiveRecord::Migration[5.2]
  def change
    add_column :cameras, :other_information, :string
  end
end
