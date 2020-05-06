class CreateCreditCards < ActiveRecord::Migration[5.2]
  def change
    create_table :credit_cards do |t|
      t.references :user
      t.string :cvv
      t.string :holder_name
      t.string :number
      t.integer :expiration_month
      t.integer :expiration_year

      t.timestamps
    end
  end
end
