class DropUnusedTables < ActiveRecord::Migration[5.2]
  def change
    drop_table :payment_transactions do |t|
      t.string :type, index: true
      t.decimal :amount

      t.timestamps
    end
  end
end
