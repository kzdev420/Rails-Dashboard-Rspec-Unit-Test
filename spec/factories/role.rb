FactoryBot.define do
  factory :role do
    name { Faker::Name.name }

    after :create do |role|
      ClassUtil.models.each do |model|
        create(:role_permission, :full, role: role, name: model)
      end
    end
  end
end
