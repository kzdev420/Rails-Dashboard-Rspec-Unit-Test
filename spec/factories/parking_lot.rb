FactoryBot.define do
  factory :parking_lot do
    email { Faker::Internet.email }
    phone { Faker::Phone.number  }
    name { Faker::Address.street_name }
    outline { JSON.parse(File.read(Rails.root.join('spec/fixtures/parking_lot.parking'))) }
    town_managers { [Admin.town_manager.first || create(:admin, role: Role.find_by(name: :town_manager) || create(:role, :town_manager))] }

    trait :with_slots do
      after :create do |lot|
        FactoryBot.create_list(:parking_slot, 5, parking_lot: lot)
      end
    end

    trait :with_camera do
      after :create do |lot|
        FactoryBot.create(:camera, parking_lot: lot)
      end
    end

    trait :with_admin do
      after :create do |lot|
        create :admin_right, subject: lot, admin: create(:admin, role: Role.find_by(name: :parking_admin) || create(:role, :parking_admin))
      end
    end

    trait :with_rules do
      after :create do |lot|
        Parking::Rule.names.keys.each do |name|
          create :parking_rule, :with_recipients, lot: lot, name: name, status: true
        end
      end
    end

    trait :with_place do
      after :create do |lot|
        create :place, parking_lot: lot
      end
    end

    after :create do |lot|
      create :location, subject: lot
      create :parking_setting, subject: lot
    end
  end
end
