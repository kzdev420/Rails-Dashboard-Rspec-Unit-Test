module Api
  module Dashboard
    class AdminPolicy < ::ApplicationPolicy

      def create?
        # record is a Role object model
        user.can_create_role?(record)
      end

      def update?
        user.can_update_role?(record.role) || record.id == user.id
      end

      def show?
        user.can_read_role?(record.role)
      end

    end
  end
end
