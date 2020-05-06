module Api
  module Dashboard
    class AgencyPolicy < ::ApplicationPolicy

      def create?
        user.admin?
      end

      def update?
        user.admin?
      end

      def search?
        user.admin?
      end

      def show?
        user.admin?
      end

    end
  end
end
