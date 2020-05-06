FactoryBot.define do
  factory :admin do
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    username { Faker::Admin.username }
    name { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
    phone { Faker::Phone.number }
    role { Role.find_by(name: :manager) || create(:role, :manager) }
  end
end
