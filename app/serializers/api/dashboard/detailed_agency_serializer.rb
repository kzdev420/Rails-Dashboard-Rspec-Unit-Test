module Api
  module Dashboard
    class DetailedAgencySerializer < AgencySerializer
      attributes :avatar

      def avatar
        url_for(object.avatar) if object.avatar.attached?
      end
    end
  end
end
