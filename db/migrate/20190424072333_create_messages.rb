class CreateMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :messages do |t|
      t.references :subject, polymorphic: true
      t.text :text
      t.references :author, polymorphic: true
      t.boolean :read, default: false

      t.timestamps
    end
  end
end
