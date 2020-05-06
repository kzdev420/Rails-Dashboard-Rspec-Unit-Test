#
# Model to handle CRUD permissions between system Models
# ## Table's Columns
# - role_id => [integer] Reference ID to a {Role role} mode
# - name => [string] Identify permission by name
# - record_create => [boolean] Indicate if the role can **create** the model
# - record_read => [boolean] Indicate if the role can **read** the model
# - record_update => [boolean] Indicate if the role can **update** the model
# - record_delete => [boolean] Indicate if the role can **delete** the model
# - created_at => [datetime]
# - updated_at => [datetime]
# @note An example can be seed at {Admin admin model}
class Role::Permission < ApplicationRecord
  belongs_to :role, touch: true
  has_many :attrs, class_name: 'Attribute', inverse_of: :permission, dependent: :destroy
  validates :name, uniqueness: { scope: [:role_id] } # table has cluster index on these 2 columns
end
