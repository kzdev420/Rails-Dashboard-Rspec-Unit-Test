class AddColumnPaymentMethodToPayment < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :payment_method, :integer
  end
end
