FactoryBot.define do
  factory :alert do
    association :subject, factory: :parking_session
    user
  end
end
