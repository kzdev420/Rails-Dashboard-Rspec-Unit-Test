FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    phone { Faker::Phone.number }

    trait(:confirmed) do
      confirmed_at { 1.day.ago }
    end

    trait(:with_vehicles) do
      after :create do |user, evaluator|
        FactoryBot.create_list(:vehicle, 5, user: user)
        FactoryBot.create(:vehicle, status: :deleted, user: user)
      end
    end

    trait(:with_avatar) do
      after :create do |user, evaluator|
        file = Rack::Test::UploadedFile.new('spec/files/test.jpg', 'image/png')
        user.avatar = { data: file }
      end
    end

  end
end
