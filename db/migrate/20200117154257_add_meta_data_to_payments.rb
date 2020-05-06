class AddMetaDataToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :meta_data, :json
  end
end
