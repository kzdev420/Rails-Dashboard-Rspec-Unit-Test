module RolesHelper
  Role::NAMES.each do |role|
    define_method "#{role}_role" do
      Role.find_by(name: role)
    end
  end
end
