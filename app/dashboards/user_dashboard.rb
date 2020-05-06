# frozen_string_literal: true

require "administrate/base_dashboard"

class UserDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    vehicles: Field::HasMany,
    id: Field::Number,
    email: Field::String,
    password: Field::String,
    first_name: Field::String,
    last_name: Field::String,
    trackers: Field::String,
    confirmation_token: Field::String,
    phone: Field::String,
    is_dev: Field::Boolean,
    created_at: Field::DateTime,
    confirmed_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :email,
    :first_name,
    :last_name,
    :vehicles,
    :id,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :email,
    :first_name,
    :last_name,
    :confirmation_token,
    :phone,
    :confirmed_at,
    :created_at,
    :updated_at,
    :vehicles,
    :is_dev,
    :trackers
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :email,
    :first_name,
    :last_name,
    :is_dev,
    :phone,
  ].freeze

  # Overwrite this method to customize how parking lots are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(parking_lot)
  #   "ParkingLot ##{parking_lot.id}"
  # end
end
