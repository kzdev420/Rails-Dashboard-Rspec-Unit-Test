FactoryBot.define do
  factory :parking_setting, class: 'Parking::Setting' do
    rate { 10.0 }
    parked { 30.minutes.to_i }
    overtime { 30.minutes.to_i }
    period { 30.minutes.to_i }
    free { 10.minutes.to_i }
    association :subject, factory: :parking_lot
  end
end
