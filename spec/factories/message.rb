FactoryBot.define do
  factory :message do
    association :subject, factory: :dispute
    association :author, factory: :admin
    association :to, factory: :user
    read { false }
    text { Faker::Lorem.sentence }
  end
end
