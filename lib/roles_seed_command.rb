class RolesSeedCommand
  def self.execute
    new.execute
  end

  def execute
    ownership = {
      system_admin: :super_admin,
      town_manager: :system_admin,
      parking_admin: :town_manager,
      manager: :town_manager,
      officer: :manager
    }

    crud_operations = {
      super_admin: %i(system_admin town_manager parking_admin manager officer),
      system_admin: %i(town_manager parking_admin manager officer),
      town_manager: %i(parking_admin),
      manager: %i(officer),
      officer: %i(),
      parking_admin: %i()
    }

    read_operations = {
      town_manager: %i(town_manager),
      manager: %i(manager),
      officer: %i(officer)
    }

    Role::NAMES.each do |role_name|
      role = Role.new(name: role_name)

      if ownership[role_name]
        role.parent = Role.find_by(name: ownership[role_name])
      end

      role.save!

      ClassUtil.models.each do |model|
        permission = role.permissions.create!(
          name: model,
          record_create: true,
          record_update: true,
          record_read: true,
          record_delete: true
        )

        model.column_names.each do |column|
          permission.attrs.create!(name: column, attr_read: true, attr_update: true)
        end
      end

      crud_operations[role_name].each do |role_crud_name|
        role.permissions.create!(
          name: role_crud_name,
          record_create: true,
          record_update: true,
          record_read: true,
          record_delete: true
        )
      end

      read_operations[role_name]&.each do |role_read_name|
        role.permissions.create!(
          name: role_read_name,
          record_read: true
        )
      end

    end

    Role.where(name: [:super_admin, :system_admin]).update_all(full: true)
  end
end
