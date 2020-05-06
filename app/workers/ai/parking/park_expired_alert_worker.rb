# We send an email to the user indicating that his parking session has expired
module Ai
  module Parking
    class ParkExpiredAlertWorker
      include Sidekiq::Worker
      sidekiq_options queue: :ai

      def perform(session_id)
        session = ParkingSession.current.find_by(id: session_id) # if it finds the session it means that still on the parking lot
        return if session.blank?

        UserNotifier.park_expired(session.user, session)

      end

      def self.schedule_alert(session)
        Sidekiq::ScheduledSet.new.each do |job|
          next if job.klass != self.name
          next if job.args.exclude?(session.id)
          job.delete
        end
        ParkWillExpireAlertWorker.schedule_alert(session)
        perform_in(session.check_out, session.id) if session.user
      end
    end
  end
end
