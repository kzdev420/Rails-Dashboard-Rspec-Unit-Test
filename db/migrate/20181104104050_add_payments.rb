class AddPayments < ActiveRecord::Migration[5.2]
  def change
    create_table :bills do |t|
      t.string :type, index: true
      t.decimal :amount

      t.timestamps
    end

    create_table :payment_transactions do |t|
      t.string :type, index: true
      t.decimal :amount

      t.timestamps
    end

    create_join_table :bills, :payment_transactions do |t|
      t.index :bill_id
      t.index :payment_transaction_id
    end

    add_column :parking_sessions, :amount, :decimal,
      null: false, default: 0
  end
end
