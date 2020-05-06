namespace :roles do
  task migrate: :environment do
    Role.transaction do
      Role.destroy_all
      RolesSeedCommand.execute
    end
  end
end
