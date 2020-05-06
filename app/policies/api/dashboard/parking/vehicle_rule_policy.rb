module Api
  module Dashboard
    module Parking
      class VehicleRulePolicy < ApplicationPolicy
        def index?
          permission.read?
        end

        def create?
          permission.create?
        end

        def archive?
          update? && permission.attribute_update?(:status)
        end

        def update?
          permission.update?
        end
      end
    end
  end
end
