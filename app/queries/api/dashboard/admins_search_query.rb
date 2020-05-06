module Api
  module Dashboard
    class AdminsSearchQuery < AdminsQuery

      def call
        scope = super
        subject_id, subject_type = options[:subject_id], options[:subject_type]

        return scope if subject_id.blank? || subject_type.blank?

        scope
          .joins(:rights)
          .where(admin_rights: { subject_id: subject_id, subject_type: subject_type })
      end
    end
  end
end
