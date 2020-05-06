module Api
  module Dashboard
    class AgenciesQuery < ApplicationQuery

      def call
        query, status, order = options[:query], options[:status], options[:order]
        scope = Agency.with_role_condition(options[:user])

        if query.present?
          sql_query = []
          attr_query = []
          %w(agencies locations).each do |model_name|
            if query[model_name.to_sym].present?
              query[model_name.to_sym].each do |attr, value|
                sql_query.push("#{model_name}.#{attr} ilike ?")
                attr_query.push("%#{value}%")
              end
            end
          end
          scope = scope.joins(:location).where(sql_query.join(' AND '), *attr_query)
        end

        if order.present?
          keyword, direction = options[:order][:keyword], options[:order][:direction]
          scope = scope.joins(:location, :admins).order(Arel.sql("#{keyword} #{direction}"))
        end
        scope = scope.where(status: status) if status.present?
        scope.eager_load(:location)
      end

    end
  end
end
