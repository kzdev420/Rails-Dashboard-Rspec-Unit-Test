module Api
  module V1
    class NotificationsQuery < ::ApplicationQuery
      def call
        types, vehicle_id, user, statuses, ids = options[:type], options[:vehicle_id], options[:user], options[:status], options[:ids]
        scope = ::User::Notification.where(user: user)

        if ids.present?
          scope = scope.where(id: ids)
        end

        if statuses.respond_to?(:reject)
          scope = scope.where(status: statuses.reject { |status| !::User::Notification.statuses.keys.include?(status.to_s) })
        end

        if types.respond_to?(:reject)
          scope = scope.where(template: types.reject { |type| !::User::Notification.templates.keys.include?(type.to_s) })
        end

        if vehicle_id
          scope = scope.joins(user: :vehicles).where(vehicles: { id: vehicle_id })
        end

        scope.where.not(parking_session_id: nil).includes(parking_session: [:vehicle]).order("user_notifications.created_at desc")
      end
    end
  end
end
