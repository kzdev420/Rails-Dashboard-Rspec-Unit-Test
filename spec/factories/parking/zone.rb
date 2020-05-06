FactoryBot.define do
  factory :parking_zone, class: 'Parking::Zone' do
    association :lot, factory: :parking_lot
    association :setting, factory: :parking_setting

    after :create do |zone|
      create :parking_setting, subject: zone
    end
  end
end
