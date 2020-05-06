##
# Model To handle the administrators permissions across all system models, avoid using it, as it might get deleted in the future
# ## Table's Columns
# - subject_type => [string] Class model of which the admin has access to
# - subject_id => [bigint] ID of which model the admin has access to
# - admin_id => [integer] admin associate to the permission
# - updated_at => [datetime]
# - created_at => [datetime]
# @deprecated please use Permission model instead, as attemps are being made to delete this model
class Admin::Right < ApplicationRecord
  self.primary_key = :admin_id
  belongs_to :subject, polymorphic: true
  belongs_to :admin
end
