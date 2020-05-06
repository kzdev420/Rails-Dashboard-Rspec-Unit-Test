module Api
  module Dashboard
    class AdminsQuery < ::ApplicationQuery
      def call
        user, role_id, status, query, role_names, parking_lots, order = options[:user], options[:role_id], options[:status], options[:query], options[:role_names], options[:parking_lots], options[:order]
        scope = Admin.joins(:role).where(roles: { id: user.role.all_allowed_to(:read).select(:id) }).where.not(id: user.id)
        scope = scope.joins(:role).where(roles: { name: role_names }).select('admins.*, roles.name') if role_names.present?
        scope = scope.where(role_id: role_id) if role_id.present?
        scope = scope.where(status: status) if status.present?
        scope = scope.joins(:parking_lots).where(parking_lots: { id: parking_lots }) if parking_lots.present?

        if query.present?
          sql_query = []
          attr_query = []
          %w(name email username).each do |attr|
            if query[attr.to_sym].present?
              sql_query.push("admins.#{attr} ilike ?")
              attr_query.push("%#{query[attr.to_sym]}%")
            end
          end
          scope = scope.where(sql_query.join(' AND '), *attr_query)
        end

        if order.present?
          keyword, direction = options[:order][:keyword], options[:order][:direction]
          scope = scope.joins(:role).order(Arel.sql("#{keyword} #{direction}"))
        else
          scope = scope.joins(:role).order(Arel.sql("admins.created_at desc"))
        end

        scope = scope.includes(:parking_lots, :role, :rights, avatar_attachment: [:blob])
        scope
      end
    end
  end
end
