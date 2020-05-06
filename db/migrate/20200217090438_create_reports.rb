class CreateReports < ActiveRecord::Migration[5.2]
  def change
    create_table :reports do |t|
      t.string :name
      t.references :type, polymorphic: true

      t.timestamps
    end
  end
end
