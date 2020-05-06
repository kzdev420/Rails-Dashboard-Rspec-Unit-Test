FactoryBot.define do
  factory :vehicle do
    plate_number { Faker::Car.number }
    color { 'Red' }
    model { 'Audi' }
    vehicle_type { 'sedan' }
    status { :active }
    manufacturer { Manufacturer.last }
    user
  end
end
