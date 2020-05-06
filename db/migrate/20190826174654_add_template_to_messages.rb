class AddTemplateToMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :template, :integer
    add_column :messages, :title, :string
    add_reference :messages, :parking_session, foreign_key: true
  end
end
