##
# Model for permission control usages, take a look at Access::Model class, There is bunch of examples of permission control usages
# ## Table's Columns
# - name => [string] How we identify the name on the system
# - full => [boolean] if it has full access to all the system features
# - parent_id => [integer] Reference to this same model
# - created_at => [datetime]
# - updated_at => [datetime]
# @see this lib/roles_seed_command.rb for current hierarchy on the system

class Role < ApplicationRecord
  has_many :admins, dependent: :nullify
  has_many :permissions, inverse_of: :role, dependent: :destroy

  with_options class_name: 'Role' do |assoc|
    assoc.has_many :children, foreign_key: :parent_id, dependent: :nullify
    assoc.belongs_to :parent, optional: true
  end

  validates :name, presence: true, uniqueness: true # also unique index is defined in db

  NAMES = [:super_admin, :system_admin, :town_manager, :parking_admin, :manager, :officer].freeze

  NAMES.each do |name|
    define_method "#{name}?" do
      self.name.to_sym == name
    end
  end

  def all_allowed_to(operation)
    permission_roles = permissions.where(name: NAMES, "record_#{operation}": true).select(:name)
    Role.where(name: permission_roles.map(&:name))
  end

end
