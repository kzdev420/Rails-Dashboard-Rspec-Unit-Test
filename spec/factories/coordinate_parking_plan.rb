FactoryBot.define do
  factory :coordinate_parking_plan do
    x { Faker::Number.between(100, 999) }
    y { Faker::Number.between(100, 999) }
    parking_slot
  end
end
