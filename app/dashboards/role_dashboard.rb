require "administrate/base_dashboard"

class RoleDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    permissions: Field::HasMany.with_options(class_name: 'Role::Permission'),
    children: Field::HasMany.with_options(class_name: "Role"),
    parent: Field::BelongsTo.with_options(class_name: "Role"),
    id: Field::Number,
    name: Field::String,
    full: Field::Boolean,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    parent_id: Field::Number,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :id,
    :name,
    :parent,
    :full
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :name,
    :full,
    :created_at,
    :updated_at,
    :children,
    :parent,
    :permissions
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :name,
    :parent,
    :full,
    :permissions,
    :children
  ].freeze

  # Overwrite this method to customize how roles are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(role)
    role.name
  end
end
