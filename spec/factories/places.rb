FactoryBot.define do
  factory :place do
    name { Faker::Company.name[1...25] }
    category { Place.categories.keys.sample }
    distance { Faker::Number.between(1, 100) }
    parking_lot
  end
end
