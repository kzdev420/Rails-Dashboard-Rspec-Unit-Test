class AddColumnNetworkToCreditCards < ActiveRecord::Migration[5.2]
  def change
    add_column :credit_cards, :network, :string
  end
end
