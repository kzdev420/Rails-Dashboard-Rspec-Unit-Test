##
# Model to handle administrator that are going to receive notification when a violation occurs
# For more information check app/interactions/parking_sessions/violation_commited.rb
# This recipients will be added through the dashboard project using the interactor under app/interactions/parking/rules/
# ## Table's Columns
# - rule_id => [bigint] Reference ID to a {Parking::Rule parking rule}
# - admin_id => [bigint]  Reference ID to a {Admin admin}
# - created_at => [datetime]
# - updated_at => [datetime]
class Parking::Recipient < ApplicationRecord
  belongs_to :rule
  belongs_to :admin
end
