# It creates a violation rules and prevent the user to pay the session anymore
module Ai
  module Parking
    class GracePeriodViolationWorker
      include Sidekiq::Worker
      sidekiq_options queue: :ai

      def perform(session_id)
        session = ParkingSession.find(session_id)
        rule = session.parking_lot.rules.find_by(name: :exceeding_grace_period)

        # It should not create any violation if the session is not with created status
        return unless session.created?

        session.update(fee_applied: session.parking_lot.rate)

        return if session.vehicle.user # App user won't be penalized by this rule

        ::ParkingSessions::ViolationCommited.run(
          parking_lot: session.parking_lot,
          uuid: session.uuid,
          timestamp: session.parked + session.check_in.to_i,
          violation_type: rule.name
        )
      end

      def self.start_counter(session)
        worker_active = false
        Sidekiq::ScheduledSet.new.each do |job|
          next if job.klass != self.name
          next if job.args.exclude?(session.id)
          worker_active = true
        end

        rule = session.parking_lot.rules.find_by(name: :exceeding_grace_period)
        perform_in(session.parked.second, session.id) if rule.status && !worker_active && session.created?
      rescue => exc
        Raven.capture_exception(exc)
      end
    end
  end
end
