class AddGatewayToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :payment_gateway, :string
  end
end
