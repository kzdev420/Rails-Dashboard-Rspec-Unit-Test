##
# Model to handle parking rules, this rules are associated to each parking lot, which means that it will be a copy (for each value on the enum :name) for every parking lot.
# This rules can be turn off/on on the dashboard project, by going to https://dashboard.telesoftmobile.com/dashboard/parking_lots/:id/rules (Change the :id value)
# ## Table's Columns
# - name => [integer] Rule name (determined by the enum :name)
# - description => [text] Rule description (determined by the enum :name before saving)
# - status => [boolean] If the rule is on or off
# - agency_id => [bigint] Reference ID to which agency will be notified when this rule happens
# - lot_id => [bigint] Reference ID to which parking lot admin will be notified
# - created_at => [datetime]
# - updated_at => [datetime]
class Parking::Rule < ApplicationRecord
  belongs_to :agency, optional: true
  belongs_to :lot, class_name: 'ParkingLot'
  has_many :recipients, dependent: :destroy
  has_many :admins, through: :recipients
  has_many :violations, dependent: :destroy

  # To generate new rules:
  # 1 - Add new rule on enum list
  # 2 - Visit dashboard.domain/dashboard/parking_lots/:lot_id/rules
  # This will trigger the index event on app/controllers/api/dashboard/parking/rules_controller.rb which creates a new rules if it doesn't exist
  enum name: {
    overlapping: 0,
    blocking_space: 1,
    leaving_halfway: 2,
    exceeding_grace_period: 3,
    unpaid: 4,
    parking_expired: 5
  }

  after_initialize do
    if description.blank? && name.present?
      locales_key = "activerecord.models.rules.description.#{name}"
      self.description = I18n.t(locales_key) if I18n.exists?(locales_key)
    end
  end

end
