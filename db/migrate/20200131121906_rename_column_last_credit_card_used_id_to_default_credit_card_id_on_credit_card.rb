class RenameColumnLastCreditCardUsedIdToDefaultCreditCardIdOnCreditCard < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :last_credit_card_used_id, :default_credit_card_id
  end
end
