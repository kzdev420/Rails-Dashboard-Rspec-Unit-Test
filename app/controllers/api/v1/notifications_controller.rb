module Api
  module V1
    class NotificationsController < ::Api::V1::ApplicationController
      # before_action :authenticate_user!

      api :GET, '/api/v1/notifications', 'Get a list of notifications'
      header :Authorization, 'Auth token from users#sign_in', required: true
      param :per_page, Integer, 'Items per page, default is 10. Check response headers for total count (key: X-Total)', required: false
      param :page, Integer, 'Items page', required: false
      param :ids, Array, of: Integer
      param :type, Array, of: User::Notification.templates.keys
      param :status, Array, of: User::Notification.statuses.keys
      param :vehicle_id, Array, of: Integer

      def index
        scope = paginate notifications_scope
        respond_with scope, each_serializer: serializer
      end

      api :GET, '/api/v1/notifications/read', 'Get all read notifications.'
      param :per_page, Integer, 'Items per page, default is 10. Check response headers for total count (key: X-Total)', required: false
      param :page, Integer, 'Items page', required: false
      param :type, Array, of: User::Notification.templates.keys
      param :vehicle_id, Integer, 'Vehicle id'
      header :Authorization, 'Auth token from users#sign_in', required: true

      def read
        scope = paginate notifications_scope(status: [:read])
        respond_with scope, each_serializer: serializer
      end

      api :PUT, '/api/v1/notifications/read', 'Mark notifications as read.'
      param :notification_ids, Array, of: Integer, desc: 'Notification ids that should be marked as read', required: true
      header :Authorization, 'Auth token from users#sign_in', required: true

      def mark_read
        User::Notification.transaction do
          User::Notification.where(id: params[:notification_ids]).where.not(status: :read).each do |notification|
            notification.update_column(:status, :read)
          end
        end

        head :ok
      rescue => exc
        Raven.capture_exception(exc)
        head :bad_request
      end

      api :GET, '/api/v1/notifications/unread', 'Get all unread notifications.'
      param :per_page, Integer, 'Items per page, default is 10. Check response headers for total count (key: X-Total)', required: false
      param :page, Integer, 'Items page', required: false
      param :type, Array, of: User::Notification.templates.keys
      param :vehicle_id, Integer, 'Vehicle id'
      header :Authorization, 'Auth token from users#sign_in', required: true

      def unread
        scope = paginate notifications_scope(status: [:unread])
        respond_with scope, each_serializer: serializer
      end

      api :PUT, '/api/v1/notifications/:id', 'Mark notification as read'
      param :id, Integer, 'Notification id', required: true
      header :Authorization, 'Auth token from users#sign_in', required: true

      def update
        notification = current_user.notifications.find(params[:id])
        notification.update_column(:status, :read)
        respond_with notification, serializer: serializer
      end

      api :GET, '/api/v1/notifications/types', 'Get all possible notification types'
      header :Authorization, 'Auth token from users#sign_in', required: true

      def types
        respond_with(User::Notification.templates.each_with_object({}) do |(template, _), memo|
          memo[template] = t("activerecord.models.user/notification.templates.#{template}_title")
        end)
      end

      private

      def notifications_scope(options={})
        ::Api::V1::NotificationsQuery.call(params.merge(user: current_user).merge(options))
      end

      def serializer
        ::Api::V1::NotificationSerializer
      end
    end
  end
end
