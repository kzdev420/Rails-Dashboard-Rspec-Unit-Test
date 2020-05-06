##
# Model to provide access to Kiosk applciation on his requests.
# It's used to authenticate requests on app/controllers/api/v1/ksk/application_controller.rb
# ## Table's Columns
# - value => [string] It stores token value
# - name => [string] identifier name
# - kiosk_id => [bigint] ID reference to {Kiosk kiosk model}
# - last_use => [datetime] last date when it was used
# - created_at => [datetime]
# - updated_at => [datetime]
class Ksk::Token < ApplicationRecord
  belongs_to :kiosk
end
