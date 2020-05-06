##
# Model to handle discussions between users and admins.
# ## Table's Columns
# - parking_session_id => [bigint] ID reference to a {ParkingSession parking session}
# - user_id => [bigint] ID reference to a {User user}
# - admin_id => [bigint] ID reference to an {Admin admin}
# - status => [integer] Three possibles statuses [opened, resolved, pending]
# - reason => [integer] Three possible reasons other, time, not_me
# - created_at => [datetime]
# - updated_at => [datetime]
class Dispute < ApplicationRecord
  belongs_to :parking_session
  belongs_to :user
  belongs_to :admin

  has_many :messages, as: :subject, dependent: :destroy

  enum status: {
    opened: 0,
    resolved: 1,
    pending: 2
  }

  enum reason: {
    other: 0,
    time: 1,
    not_me: 2
  }

  # It helps to handle the access that each roles has on the system
  # to be able to interact with a dispute
  # @return ActiveRecord::Relation of {Dispute dispute model}
  def self.with_role_condition(admin)
    scope = all

    case admin.role.name.to_sym
    when :system_admin, :super_admin
      scope
    when :parking_admin
      admin.disputes
    when :town_manager
      admin.disputes.joins(admin: :role).where(disputes: { admins: { roles: { name: :town_manager } } })
    else
      scope.none
    end
  end
end
