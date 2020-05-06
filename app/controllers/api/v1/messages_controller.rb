module Api
  module V1
    class MessagesController < ::Api::V1::ApplicationController
      # before_action :authenticate_user!

      api :GET, '/api/v1/messages', 'Get a list of messages'
      header :Authorization, 'Auth token from users#sign_in', required: true
      param :per_page, Integer, 'Items per page, default is 10. Check response headers for total count (key: X-Total)', required: false
      param :ids, Array, of: Integer
      param :page, Integer, 'Items page', required: false
      param :types, ::Message.templates.keys, 'Types of Message'
      param :query, String, 'Search by the message content or title'

      def index
        scope = paginate messages_scope
        respond_with scope, each_serializer: serializer
      end

      api :PUT, '/api/v1/messages/read', 'Mark messages as read.'
      param :message_ids, Array, of: Integer, desc: 'Messages ids that should be marked as read', required: true
      header :Authorization, 'Auth token from users#sign_in', required: true

      def mark_read
        Message.transaction do
          Message.where(id: params[:message_ids]).where.not(read: true).each do |message|
            message.update!(read: true)
          end
        end

        head :ok
      rescue => exc
        Raven.capture_exception(exc)
        head :bad_request
      end

      api :GET, '/api/v1/messages/types', 'Get all possible messages types'
      header :Authorization, 'Auth token from users#sign_in', required: true

      def types
        respond_with(Message.templates.each_with_object({}) do |(template, _), memo|
          memo[template] = t("activerecord.models.message.templates.#{template}_title")
        end)
      end

      api :GET, '/api/v1/messages/unread', 'Get unread messages.'
      header :Authorization, 'Auth token from users#sign_in', required: true

      def unread
        scope = paginate messages_scope(read: false)
        respond_with scope, each_serializer: serializer
      end

      private

      def messages_scope(options={})
        ::Api::V1::MessagesQuery.call(params.merge(user: current_user).merge(options))
      end

      def serializer
        ::Api::V1::MessageSerializer
      end
    end
  end
end
