module Api
  module Dashboard
    class UserSerializer < ::ApplicationSerializer
      attributes :id, :avatar, :username, :email, :name, :status, :parking_lots
      attribute :actions, if: -> { not_current_user }

      has_one :role, serializer: Api::Dashboard::ThinRoleSerializer

      def avatar
        url_for(object.avatar) if object.avatar.attached?
      end

      def parking_lots
        object.parking_lots.map do |lot|
          {
            id: lot.id,
            name: lot.name
          }
        end
      end

      def actions
        role_permission = current_user.role.permissions.find_by(name: object.role.name)
        {
          update: role_permission.nil? ? true : role_permission.record_update,
          delete: role_permission.record_delete
        }
      end

      private

      def not_current_user
        current_user.id != object.id
      end

    end
  end
end
