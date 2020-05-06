module Api
  module Dashboard
    class AgencySerializer < ::ApplicationSerializer
      attributes :id, :name, :location, :email, :phone, :manager, :town_manager, :officers, :status

      def manager
        if user = object.manager
          {
            id: user.id,
            username: user.username,
            name: user.name
          }
        end
      end

      def town_manager
        if user = object.town_manager
          {
            id: user.id,
            username: user.username,
            name: user.name
          }
        end
      end

      def officers
        ActiveModel::Serializer::CollectionSerializer.new(
          object.officers,
          serializer: ::Api::Dashboard::ThinAdminSerializer
        )
      end

      def location
        ::LocationSerializer.new(object.location)
      end
    end
  end
end
