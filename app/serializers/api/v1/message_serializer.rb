module Api
  module V1
    class MessageSerializer < ::ApplicationSerializer
      attributes :id, :text, :read, :title, :created_at, :type

      def type
        object.template
      end

      def read
        object.read?
      end
    end
  end
end
