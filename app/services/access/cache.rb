module Access
  class Cache < SimpleDelegator
    include Singleton

    def initialize
      @storage = {}
      super(@storage)
    end

    def warm_up
      Role.all.includes(permissions: :attrs).each do |role|
        @storage[role.id] = permissions_for(role)
      end
    end

    alias :reset :warm_up

    def [](role_id)
      role_cache = @storage[role_id]

      unless role_cache
        return with_preload_role(role_id)
      end

      role = Role.select(:updated_at).find(role_id)

      if role_cache[:version] == role.cache_version
        role_cache
      else
        with_preload_role(role_id)
      end
    end

    private

    def permissions_for(role)
      role_cache = {
        version: role.cache_version
      }.with_indifferent_access

      role.permissions.each do |permission|
        permissions_cache = role_cache[permission.name] = {
          create: permission.record_create,
          read: permission.record_read,
          update: permission.record_update,
          delete: permission.record_delete
        }.with_indifferent_access

        attributes_cache = permissions_cache[:attributes] = {}.with_indifferent_access

        permission.attrs.each do |attr_permission|
          attributes_cache[attr_permission.name] = {
            read: attr_permission.attr_read,
            update: attr_permission.attr_update
          }.with_indifferent_access
        end
      end

      role_cache
    end

    def with_preload_role(role_id)
      @storage[role_id] = permissions_for(Role.includes(permissions: :attrs).find(role_id))
    end
  end
end
