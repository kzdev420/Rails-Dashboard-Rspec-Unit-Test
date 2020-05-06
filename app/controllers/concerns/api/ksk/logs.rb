module Api
  module Ksk
    module Logs
      extend ActiveSupport::Concern

      included do
        after_action :generate_logs

        def generate_logs
          dir = File.dirname("#{Rails.root}/log/ksk/kiosk_#{current_kiosk.id}.log")
          FileUtils.mkdir_p(dir) unless File.directory?(dir)
          session_uuid = "UUID: #{@session.uuid}\n" if @session.present?
          # Logs by Kiosk ID
          ksk_logger = Logger.new("#{Rails.root}/log/ksk/kiosk_#{current_kiosk.id}.log")
          ksk_logger.info("[#{controller_name}##{action_name}]\n#{session_uuid}params sent: #{params.to_unsafe_hash}\nbody response: #{response.body}\ncode response: #{response.code}")
        end
      end
    end
  end
end
