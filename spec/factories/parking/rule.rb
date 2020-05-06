FactoryBot.define do
  factory :parking_rule, class: 'Parking::Rule' do
    name { Parking::Rule.names.keys.sample }
    association :lot, factory: :parking_lot
    agency

    trait :with_recipients do
      after :create do |rule|
        create :parking_recipient, rule: rule
      end
    end
  end
end
