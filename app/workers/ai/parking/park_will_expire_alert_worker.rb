# We send an email to the user indicating that his parking session is about to expired
module Ai
  module Parking
    class ParkWillExpireAlertWorker
      include Sidekiq::Worker
      sidekiq_options queue: :ai

      def perform(session_id)
        session = ParkingSession.current.find_by(id: session_id) # if it finds the session it means that still on the parking lot
        return if session.blank?

        UserNotifier.park_will_expire(session.user, session)
      end

      def self.schedule_alert(session)
        Sidekiq::ScheduledSet.new.each do |job|
          next if job.klass != self.name
          next if job.args.exclude?(session.id)
          job.delete
        end

        perform_in(session.check_out - 15.minutes.second.to_i, session.id) if session.user
      end
    end
  end
end
