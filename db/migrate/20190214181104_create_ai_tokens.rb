class CreateAiTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :ai_tokens do |t|
      t.string :value, index: true
      t.string :name
      t.datetime :last_use
      t.timestamps
    end
  end
end
