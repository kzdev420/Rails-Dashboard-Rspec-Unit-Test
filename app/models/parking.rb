##
# Namespace container for Parking related model
module Parking
  # Function to avoid adding prefix to Parking child classes manually,
  # For more detailed explanation, please see: https://makandracards.com/makandra/47198-rails-namespacing-models-with-table_name_prefix-instead-of-table_name
  def self.table_name_prefix
    'parking_'
  end
end
