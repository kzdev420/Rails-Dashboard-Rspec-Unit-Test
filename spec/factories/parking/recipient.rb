FactoryBot.define do
  factory :parking_recipient, class: 'Parking::Recipient' do
    association :rule, factory: :parking_rule
    admin
  end
end
