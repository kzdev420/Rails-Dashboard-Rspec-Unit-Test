class LocationSerializer < ::ApplicationSerializer
  attributes :lng,
    :ltd,
    :street,
    :building,
    :country,
    :state,
    :city,
    :full_address,
    :zip
end
