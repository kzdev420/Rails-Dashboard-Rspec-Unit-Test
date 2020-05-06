##
# Namespace container for AI related model
module Ai
  # Function to avoid adding prefix to Ai child classes manually,
  # For more detailed explanation, please see: https://makandracards.com/makandra/47198-rails-namespacing-models-with-table_name_prefix-instead-of-table_name
  def self.table_name_prefix
    'ai_'
  end
end
