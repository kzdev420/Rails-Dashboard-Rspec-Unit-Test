module ParkingSessions
  class CarExit < BaseEvent
    include Logging

    attr_reader :user, :parking_lot

    validate :should_abort?

    set_callback :validate, :before, -> do
      return if session.present? # Avoid execute mutliple times when validations happen
      set_session
      initialize_session do |vehicle|
        {
          vehicle: vehicle,
          parking_lot: parking_lot,
          uuid: uuid
        }
      end
      set_parking_lot
    end

    def execute
      return if session_finished?

      unless vehicle
        errors.add(:vehicle, :invalid) and return
      end

      # In case the AI didn't detect when car left the parking slot but detect when exited the parking lot
      if session.ai_status.to_sym == :parked
        ::ParkingSessions::CarLeft.run(inputs.merge(parking_slot_id: session.parking_slot.name))
        session.reload
      end

      session.update!(
        exit_at: Time.at(timestamp),
        status: :finished,
        ai_status: :exited
      )
      notify_user if @user = vehicle.user
      notify_admin unless vehicle.recognized?
      check_payment
    end

    private

    def notify_admin
      ParkingAdminMailer.unrecognized_exit(parking_lot).deliver_later
    end

    def notify_user
      UserNotifier.car_exit(user, session)
    end

    def check_payment
      @unpaid_rule = session.parking_lot.rules.find_by(name: :unpaid)

      return if user_doesnt_need_to_pay?

      transactional_compose!(::ParkingSessions::ViolationCommited, {
        parking_lot: session.parking_lot,
        uuid: session.uuid,
        timestamp: timestamp,
        violation_type: @unpaid_rule.name
      })

    end

    def user_doesnt_need_to_pay?
      return true if session.fee_applied.blank?
      !@unpaid_rule.status ||
      session.paid?
    end
  end
end
