class CreateDisputes < ActiveRecord::Migration[5.2]
  def change
    create_table :disputes do |t|
      t.references :parking_session, foreign_key: true
      t.references :user
      t.references :admin
      t.integer :status, default: 0
      t.integer :reason, default: 0

      t.timestamps
    end
  end
end
