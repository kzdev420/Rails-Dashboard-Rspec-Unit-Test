# frozen_string_literal: true

require "administrate/base_dashboard"

class ParkingSessionDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    parking_lot: Field::BelongsTo.with_options(searchable: true, searchable_field: :id),
    parking_slot: Field::BelongsTo,
    logs: Field::HasMany.with_options(class_name: 'PaperTrail::Version'),
    vehicle: Field::BelongsTo,
    id: Field::Number.with_options(direction: :desc),
    check_in: Field::DateTime,
    check_out: Field::DateTime,
    parked_at: Field::DateTime,
    left_at: Field::DateTime,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    status: Field::Select.with_options(collection: ParkingSession.statuses.keys),
    uuid: Field::String,
    images: ImagesField
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :id,
    :status,
    :check_in,
    :check_out,
    :parking_slot,
    :vehicle,
    :uuid
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :uuid,
    :check_in,
    :status,
    :check_out,
    :created_at,
    :updated_at,
    :parking_lot,
    :parking_slot,
    :vehicle,
    :logs,
    :images
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :status,
    :uuid,
    :check_in,
    :check_out,
    :left_at,
    :parked_at,
    :parking_lot,
    :parking_slot,
    :vehicle,
  ].freeze

  # Overwrite this method to customize how parking sessions are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(parking_session)
  #   "ParkingSession ##{parking_session.id}"
  # end
end
