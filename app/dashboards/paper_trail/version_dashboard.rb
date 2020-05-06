# frozen_string_literal: true

require "administrate/base_dashboard"

class PaperTrail::VersionDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    comment: Field::String,
    changeset: Field::String.with_options(truncate: 400),
    created_at: Field::DateTime.with_options(format: "%Y-%m-%d %H:%M:%S %z")
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :comment,
    :changeset,
    :created_at
  ].freeze

end
