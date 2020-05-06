class AddColumnCardLastFourDigitsToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :card_last_four_digits, :string
  end
end
