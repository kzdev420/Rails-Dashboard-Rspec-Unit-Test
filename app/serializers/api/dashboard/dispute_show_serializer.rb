module Api
  module Dashboard
    class DisputeShowSerializer < DisputeSerializer
      attribute :created_at do
        utc(object.created_at)
      end

      attribute :admin, if: -> { false }

      has_many :messages, serializer: MessageSerializer

      def author
        object.user.as_json(only: [:id, :email, :first_name, :last_name])
      end

      def parking_session
        super.merge(ai_status: object.parking_session.ai_status)
      end
    end
  end
end
