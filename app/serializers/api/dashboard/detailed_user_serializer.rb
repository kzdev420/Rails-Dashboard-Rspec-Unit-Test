module Api
  module Dashboard
    class DetailedUserSerializer < UserSerializer
      attributes :avatar, :phone

      def avatar
        url_for(object.avatar) if object.avatar.attached?
      end
    end
  end
end
