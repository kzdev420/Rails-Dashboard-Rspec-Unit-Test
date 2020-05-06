module Api
  module Dashboard
    class ReportSerializer < ApplicationSerializer
      attributes :id, :name, :type_name

      attribute :created_at do
        utc(object.created_at)
      end

      def type_name
        object.type.class.name.underscore.humanize
      end

    end
  end
end
