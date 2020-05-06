#
# Model to handle RU permissions for attribute's Model
# ## Table's Columns
# - permission_id => [integer] Reference ID to a {Role::Permission role permission}
# - name => [string] Name of the attribute to handle
# - attr_read => [boolean] Indicates if the attribute can be read
# - attr_update => [boolean] Indicates if the attribute can be updated
# - created_at => [datetime]
# - updated_at => [datetime]
# @note We use Access::Attribute for to general handling of this model
class Role::Permission::Attribute < ApplicationRecord
  belongs_to :permission, touch: true
  validates :name, uniqueness: { scope: [:permission_id] } # table has cluster index on these 2 columns
end
