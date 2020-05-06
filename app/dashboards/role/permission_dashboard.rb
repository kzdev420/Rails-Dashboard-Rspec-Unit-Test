require "administrate/base_dashboard"

class Role::PermissionDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    role: Field::BelongsTo,
    attrs: Field::HasMany.with_options(class_name: 'Role::Permission::Attribute'),
    id: Field::Number,
    name: Field::String,
    record_create: Field::Boolean,
    record_read: Field::Boolean,
    record_update: Field::Boolean,
    record_delete: Field::Boolean,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :id,
    :name,
    :record_create,
    :record_read,
    :record_update,
    :record_delete
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :name,
    :role,
    :attrs,
    :record_create,
    :record_read,
    :record_update,
    :record_delete,
    :created_at,
    :updated_at,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :name,
    :role,
    :attrs,
    :record_create,
    :record_read,
    :record_update,
    :record_delete,
  ].freeze

  # Overwrite this method to customize how permissions are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(permission)
    permission.name
  end
end
