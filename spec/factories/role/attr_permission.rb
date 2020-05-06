FactoryBot.define do
  factory :role_attr_permission, class: 'Role::Permission::Attribute' do
    association :permission, factory: :role_permission

    trait :full do
      attr_read { true }
      attr_update { true }
    end
  end
end
