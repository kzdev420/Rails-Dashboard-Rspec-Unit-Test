class AddColumnLastCreditCardUsedToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :last_credit_card_used_id, :integer
    add_index :users, :last_credit_card_used_id
  end
end
