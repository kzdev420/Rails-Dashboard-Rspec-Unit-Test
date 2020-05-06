class CreateKskTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :ksk_tokens do |t|
      t.string :value, index: true
      t.string :name
      t.references :kiosk, foreign_key: true
      t.datetime :last_use

      t.timestamps
    end
  end
end
