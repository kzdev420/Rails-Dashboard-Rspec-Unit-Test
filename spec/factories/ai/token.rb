FactoryBot.define do
  factory :ai_token, class: Ai::Token do
    value { SecureRandom.hex(40) }
    name { "#{Faker::Name.first_name}_token" }
  end
end
