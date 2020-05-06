require "administrate/base_dashboard"

class Parking::SettingDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    lot: Field::BelongsTo.with_options(class_name: "ParkingLot"),
    id: Field::Number,
    rate: Field::Number.with_options(decimals: 2),
    parked: Field::Number,
    overtime: Field::Number,
    period: Field::Number,
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
    :lot,
    :rate,
    :parked,
    :overtime,
    :period
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :lot,
    :rate,
    :parked,
    :overtime,
    :period,
    :created_at,
    :updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :rate,
    :parked,
    :overtime,
    :period
  ].freeze

  # Overwrite this method to customize how settings are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(setting)
    "Parking setting ##{setting.id}"
  end
end
