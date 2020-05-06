class CreateAgencies < ActiveRecord::Migration[5.2]
  def change
    create_table :agencies do |t|
      t.string :name
      t.string :email
      t.integer :status, default: 0
      t.integer :contact_person_id, index: true
      t.string :avatar
      t.timestamps
    end
  end
end
