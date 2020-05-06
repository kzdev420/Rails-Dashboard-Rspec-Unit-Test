module Api
  module Ai
    module Logs
      extend ActiveSupport::Concern

      included do
        after_action :generate_logs

        def generate_logs
          if @result.present? && params[:parking_session].present?
            dir = File.dirname("#{Rails.root}/log/ai/parking_lot_#{parking_lot.id}.log")
            FileUtils.mkdir_p(dir) unless File.directory?(dir)
            slot_id = params[:parking_session][:parking_slot_id] # It says ID but it refers to slot_name
            uuid = params[:parking_session][:uuid].present? ? params[:parking_session][:uuid] : 'Not declared'

            @printed_params = params.to_unsafe_hash.clone
            @response_body = JSON.parse(response.body)
            filter_images(:vehicle_images)
            filter_images(:parking_images)
            filter_response_body(:images)
            # Logs by parking slot
            if slot_id.present?
              slot_logger = Logger.new("#{Rails.root}/log/ai/parking_lot_#{parking_lot.id}_slot_#{slot_id}.log")
              slot_logger.info("\n[#{action_name}]\nUUID: #{uuid}\nparams sent: #{@printed_params}\nbody response: #{@response_body}\ncode response: #{response.code}")
            end
            # Logs by Parking Lot
            lot_logger = Logger.new("#{Rails.root}/log/ai/parking_lot_#{parking_lot.id}.log")
            lot_logger.info("\n[#{action_name}]\nUUID: #{uuid}\nparams sent: #{@printed_params}\nbody response: #{@response_body}\ncode response: #{response.code}")
          end
        end

        private

        def filter_images(key)
          images = @printed_params[:parking_session][key.to_sym]
          return if images.nil?
          @printed_params[:parking_session][key.to_sym] = images.map { |img| "#{img.chars.take(30).join}..." } unless images.empty?
        end

        def filter_response_body(key)
          return if @response_body['vehicle'].nil?
          vehicle_images_urls = @response_body['vehicle'][key.to_s]
          images_urls = @response_body[key.to_s]
          unless  vehicle_images_urls.nil?
            @response_body['vehicle'][key.to_s] = '[FILTERED]' unless vehicle_images_urls.empty?
          end
          unless images_urls.nil?
            @response_body[key.to_s] = '[FILTERED]' unless images_urls.empty?
          end
        end

      end
    end
  end
end
