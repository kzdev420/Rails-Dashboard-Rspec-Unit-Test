# frozen_string_literal: true

require "administrate/base_dashboard"

class ParkingSlotDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    parking_sessions: Field::HasMany,
    parking_lot: Field::BelongsTo,
    id: Field::Number,
    name: Field::String,
    archived: Field::Boolean,
    category: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    status: Field::Select.with_options(collection: ParkingSlot.statuses.keys),
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :id,
    :status,
    :name,
    :parking_lot,
    :archived
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :name,
    :status,
    :archived,
    :created_at,
    :updated_at,
    :parking_sessions
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :status,
    :archived,
    :name,
    :parking_lot
  ].freeze

  # Overwrite this method to customize how parking slots are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(parking_slot)
  #   "ParkingSlot ##{parking_slot.id}"
  # end
end
