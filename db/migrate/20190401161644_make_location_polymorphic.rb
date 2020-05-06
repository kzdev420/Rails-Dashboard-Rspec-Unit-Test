class MakeLocationPolymorphic < ActiveRecord::Migration[5.2]
  def up
    add_reference :locations, :subject, polymorphic: true, index: true
    remove_reference :locations, :parking_lot, index: true
  end

  def down
    add_reference :locations, :parking_lot, index: true
    remove_reference :locations, :subject, polymorphic: true, index: true
  end
end
