FactoryBot.define do
  factory :parking_violation, class: 'Parking::Violation' do
    association :vehicle_rule, factory: :parking_vehicle_rule
    association :rule, factory: :parking_rule
    association :session, factory: :parking_session
    description { Faker::ChuckNorris.fact }
    fixed_at { DateTime.now }

    trait :with_image do
      after :create do |violation|
        # violation.images << create(:parking_image)
      end
    end
  end
end
