module Ai
  ##
  # Model to provide access to ai project on his requests.
  # It's used to authenticate requests on app/controllers/api/v1/ai/application_controller.rb
  # ## Table's Columns
  # - value => [string] It stores token value
  # - name => [string] identifier name
  # - last_use => [datetime] last date when it was used
  # - created_at => [datetime]
  # - updated_at => [datetime]
  class Token < ::ApplicationRecord
  end
end
