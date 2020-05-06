module Api
  module Dashboard
    class CameraPolicy < ApplicationPolicy
      def index?
        true # Everyone case access index camera page for now
      end

      def show?
        user.admin? || record.allowed
      end

      def create?
        user.admin?
      end

      def update?
        user.admin?
      end
    end
  end
end
