# frozen_string_literal: true

module ApplicationHelper
    def formatted_datetime(datetime, time = true, date = true)
        format = []
        format.push('%B %d, %Y') if date.present?
        format.push('%I:%M %p') if time.present?
        datetime.in_time_zone('Eastern Time (US & Canada)').strftime(format.join(', '))
    end
end
