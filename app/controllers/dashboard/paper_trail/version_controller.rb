module Dashboard
  module PapperTrail
    class VersionController < ApplicationController
      def valid_action?(name, resource = resource_class)
        if name.to_s == 'edit' || name.to_s == 'destroy' || name.to_s == 'create'
          return false
        end
        !!routes.detect do |controller, action|
          controller == resource.to_s.underscore.pluralize && action == name.to_s
        end
      end
    end
  end
end
