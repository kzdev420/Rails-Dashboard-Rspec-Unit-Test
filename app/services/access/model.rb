# role permission control module
# mostly should be used from ActionPolicy layer or other authorization gems' layers
# where you usually have user and class/record
# api for usage should look like this
# @Examples:
# Access::Model.new(user, ClassOrClassName).create?
# Access::Model.new(user, ClassOrClassName).read?
# Access::Model.new(user, ClassOrClassName).update?
# Access::Model.new(user, ClassOrClassName).delete?
#
# Access::Model.new(user, ClassOrClassName).attribute_read(attribute_name_from_model)?
# Access::Model.new(user, ClassOrClassName).attribute_update?(attribute_name_from_model)?
#
# Access::Model.new(user, ClassOrClassName).attributes_read?(attribute_names_from_model)?
# Access::Model.new(user, ClassOrClassName).attributes_update?(attribute_names_from_model)?

module Access
  class Model < Struct.new(:user, :model)
    delegate :role, to: :user

    [:create, :read, :update, :delete].each do |action|
      define_method "#{action}?" do
        return true if role.full?
        permissions ? permissions[action] : false
      end
    end

    [:attribute, :attributes].each do |scope|
      [:read, :update].each do |action|
        define_method "#{scope}_#{action}?" do |*args|
          return true if role.full?
          scope.to_s.camelize.constantize.new(permissions[:attributes]).send("#{action}?", *args)
        end
      end
    end

    def permissions
      @permissions ||= Access::Cache.instance[role.id][model.to_s]
    end

    private :permissions
  end
end
