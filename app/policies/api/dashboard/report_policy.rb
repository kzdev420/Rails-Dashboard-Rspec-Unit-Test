module Api
  module Dashboard
    class ReportPolicy < ApplicationPolicy
      def index?
        user.admin?
      end
    end
  end
end
