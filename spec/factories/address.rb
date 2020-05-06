FactoryBot.define do
  factory :address, class: Effective::Address do
    address1   { Faker::Address.street_name }
    postal_code { Faker::Address.zip(Faker::Address.state_abbr) }
    country_code { ["BO", "BQ", "BR", "BS", "BT", "BV", "BW", "BY", "BZ", "CC", "CD", "CF", "CG", "CH" ].sample }
    state_code { Faker::Address.state_abbr }
    city { Faker::Address.city }
  end
end
