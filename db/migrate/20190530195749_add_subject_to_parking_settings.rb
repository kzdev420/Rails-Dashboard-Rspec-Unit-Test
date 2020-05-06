class AddSubjectToParkingSettings < ActiveRecord::Migration[5.2]
  def change
    remove_reference :parking_settings, :lot, foreign_key: { to_table: :parking_lots }
    add_reference :parking_settings, :subject, polymorphic: true
  end
end
