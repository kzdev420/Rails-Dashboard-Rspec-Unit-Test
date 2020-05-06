# It sends to the admin that the parking time has expired and a violation will be raised
module Ai
  module Parking
    class OvertimeTickerWorker
      include Sidekiq::Worker
      sidekiq_options queue: :ai

      def perform(session_id)
        session = ParkingSession.current.find_by(id: session_id) # if it finds the session it means that still on the parking lot
        return if session.blank?

        rule = session.parking_lot.rules.find_by(name: :parking_expired)

        if rule.status
          ::ParkingSessions::ViolationCommited.run(
            parking_lot: session.parking_lot,
            uuid: session.uuid,
            timestamp: session.check_out.to_i + session.overtime,
            violation_type: rule.name
          )
          ParkingAdminMailer.park_expired(session).deliver_later
        end

      end

      def self.extend_or_create(session)
        Sidekiq::ScheduledSet.new.each do |job|
          next if job.klass != self.name
          next if job.args.exclude?(session.id)
          job.delete
        end
        ParkExpiredAlertWorker.schedule_alert(session)
        perform_in(session.check_out + session.overtime, session.id)
      end
    end
  end
end
