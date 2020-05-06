FactoryBot.define do
  factory :location do
    country { Faker::Address.country  }
    city { Faker::Address.city }
    building { Faker::Address.building_number }
    state { Faker::Address.state }
    street { Faker::Address.street_name }
    ltd { Faker::Address.latitude.to_f }
    lng { Faker::Address.longitude.to_f }
    zip { Faker::Address.zip(Faker::Address.state_abbr) }
  end
end
