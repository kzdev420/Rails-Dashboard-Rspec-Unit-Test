##
# This model is being used to notify a user that a car related to his account has parked. (This is the only functionality for now)
# It's created on app/interactions/parking_sessions/car_parked.rb
# @see https://telsoft.atlassian.net/browse/PSAD-168 PSAD-168
# ## Table's Columns
# - type => [integer] Type specified on the enum type
# - subject_type => [string] Class model associated to the alert
# - subject_id => [bigint] ID of model type
# - status => [integer] Type specified on the enum status (Opened or Resolved)
# - user_id => [bigint] ID reference to the {User user model}
# - created_at => [datetime]
# - updated_at => [datetime]
class Alert < ApplicationRecord
  self.inheritance_column = 'sti_type' # change column due to `type` existing usage

  belongs_to :subject, polymorphic: true
  belongs_to :user

  enum status: {
    opened: 0,
    resolved: 1, # User interacted with alert
    pending: 2 # User didn't interact with alert before car left space
  }

  enum type: {
    parking_confirmation: 0
  }
end
