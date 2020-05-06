class DropTableBills < ActiveRecord::Migration[5.2]
  def change
    drop_table :bills do |t|
      t.string :type, index: true
      t.decimal :amount

      t.timestamps
    end
  end
end
