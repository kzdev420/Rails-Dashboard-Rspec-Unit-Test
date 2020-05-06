module Access
  class Admin < Struct.new(:admin, :role_name)

    [:create, :read, :update, :delete].each do |action|
      define_method "#{action}?" do
        return true if admin.role.full?
        permissions ? permissions[action] : false
      end
    end

    def permissions
      @permissions ||= Access::Cache.instance[admin.role.id][role_name]
    end

    private :permissions
  end
end
