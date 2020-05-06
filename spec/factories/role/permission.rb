FactoryBot.define do
  factory :role_permission, class: 'Role::Permission' do
    role

    trait :full do
      record_create { true }
      record_read { true }
      record_update { true }
      record_delete { true }

      after :create do |permission|
        permission.name.constantize.column_names.each do |column|
          create(:role_attr_permission, :full, permission: permission, name: column)
        end
      end
    end
  end
end
