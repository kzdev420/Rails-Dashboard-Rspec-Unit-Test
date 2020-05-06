module Api
  module V1
    class MessagesQuery < ::ApplicationQuery
      def call
        user, read, types, vehicle_id, query, ids = options[:user], options[:read], options[:types], options[:vehicle_id], options[:query], options[:ids]
        scope = ::Message.where(to: user).order(created_at: :desc)

        if ids.present?
          scope = scope.where(id: ids)
        end

        unless read.nil?
          scope = scope.where(read: read)
        end

        if types.present?
          scope = scope.where(template: types.map { |type| Message.templates[type] })
        end

        if query.present?
          sql_query = "messages.text ilike ? OR messages.title ilike ?", "%#{query}%", "%#{query}%"
          scope = scope.where(sql_query)
        end

        if vehicle_id.present?
          scope = scope.joins(parking_session: :vehicle).where(vehicles: { id: vehicle_id })
        end

        scope
      end
    end
  end
end
