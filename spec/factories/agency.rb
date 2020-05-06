FactoryBot.define do
  factory :agency do
    name { Faker::Company.name }
    email { Faker::Internet.email }
    phone { Faker::Phone.number }

    after :create do |agency|
      create :location, subject: agency
    end
  end
end
