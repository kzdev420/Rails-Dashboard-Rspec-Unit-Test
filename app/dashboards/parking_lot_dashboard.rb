# frozen_string_literal: true

require "administrate/base_dashboard"

class ParkingLotDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    parking_slots: Field::HasMany,
    kiosks: Field::HasMany,
    location: Field::HasOne,
    status: Field::String,
    id: Field::Number,
    outline: JsonFileField,
    parking_admin: ParkingAdminField,
    town_manager: TownManagerField,
    avatar: FileField,
    phone: Field::String,
    email: Field::String,
    name: Field::String,
    setting: Field::HasOne.with_options(class_name: 'Parking::Setting'),
    rate: Field::Number.with_options(prefix: '$', suffix: '/h'),
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
    :rate,
    :email,
    :outline
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :email,
    :name,
    :created_at,
    :updated_at,
    :parking_slots,
    :kiosks,
    :outline,
    :location,
    :setting
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :outline
  ].freeze

  # Overwrite this method to customize how parking lots are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(parking_lot)
    parking_lot.name
  end
end
