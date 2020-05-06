FactoryBot.define do
  factory :parking_slot do
    name { Faker::Parking.slot }
    parking_lot
  end
end
