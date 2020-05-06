module Dashboard
  class Roles::PermissionsController < AdministrateController
    # To customize the behavior of this controller,
    # you can overwrite any of the RESTful actions. For example:
    #
    # def index
    #   super
    #   @resources = Role::Permission.
    #     page(params[:page]).
    #     per(10)
    # end

    # Define a custom finder by overriding the `find_resource` method:
    # def find_resource(param)
    #   Role::Permission.find_by!(slug: param)
    # end

    # See https://administrate-prototype.herokuapp.com/customizing_controller_actions
    # for more information
    alias :old_dashboard_role_permission_attribute_path :dashboard_role_permission_attribute_path

    def dashboard_role_permission_attribute_path(attribute)
      old_dashboard_role_permission_attribute_path(attribute.permission.role_id, attribute.permission_id, attribute.id)
    end

    helper_method :dashboard_role_permission_attribute_path
  end
end
