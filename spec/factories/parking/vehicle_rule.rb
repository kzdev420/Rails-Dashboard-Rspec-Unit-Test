FactoryBot.define do
  factory :parking_vehicle_rule, class: 'Parking::VehicleRule' do
    association :lot, factory: :parking_lot
    vehicle
    color { Faker::Vehicle.color }
    vehicle_type { Faker::Vehicle.car_type }
  end
end
