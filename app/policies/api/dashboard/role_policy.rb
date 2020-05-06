module Api
  module Dashboard
    class RolePolicy < ApplicationPolicy
      def index?
        user.admin?
      end
    end
  end
end
