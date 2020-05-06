module Api
  module Dashboard
    class ReportQuery < ::ApplicationQuery
      def call
        name, created_at, type = options[:name], options[:created_at], options[:type]
        scope = Report.all.includes(:type)

        scope = scope.where("name ilike ?", "%#{name}%") if name.present?

        scope = scope.where("type_type ilike ?", "%#{type.gsub(/\s+/, "")}%") if type.present?

        if options[:range].present?
          from = options.dig(:range, :from).to_date
          to = options.dig(:range, :to).blank? ? DateTime::Infinity.new : options.dig(:range, :to).to_date.end_of_day
          scope = scope.where(created_at: from.beginning_of_day..to) if from.present? && to.present?
        end

        scope.order(created_at: :desc)
      end
    end
  end
end