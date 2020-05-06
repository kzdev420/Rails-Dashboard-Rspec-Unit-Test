FactoryBot.define do
  factory :ksk_token, class: 'Ksk::Token' do
    value { SecureRandom.hex(40) }
    name { "#{Faker::Name.first_name}_token" }
    kiosk
    last_use { DateTime.now }
  end
end
