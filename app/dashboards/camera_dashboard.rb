require "administrate/base_dashboard"

class CameraDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    parking_lot: Field::BelongsTo,
    id: Field::Number,
    stream: Field::String,
    login: Field::String,
    name: Field::String,
    other_information: Field::String,
    vmarkup: JsonFileField,
    password: Field::Password,
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
    :stream,
    :login,
    :vmarkup
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :name,
    :stream,
    :login,
    :password,
    :parking_lot,
    :created_at,
    :updated_at,
    :vmarkup,
    :other_information
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :name,
    :login,
    :password,
    :stream,
    :parking_lot,
    :vmarkup,
    :other_information
  ].freeze

  # Overwrite this method to customize how cameras are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(camera)
  #   "Camera ##{camera.id}"
  # end
end
