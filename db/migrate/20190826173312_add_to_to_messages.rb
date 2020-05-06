class AddToToMessages < ActiveRecord::Migration[5.2]
  def change
    add_reference :messages, :to, polymorphic: true
  end
end
