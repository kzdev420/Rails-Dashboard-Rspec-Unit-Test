module ParkingSessions
  class Extend < ::ApplicationInteraction

    integer :check_out, default: 30.minutes.from_now.to_i
    object :object, class: ParkingSession

    validate do
      if check_out < object.check_in.to_i
        errors.add(:check_out, :less_than_check_in)
        throw(:abort)
      end
      if object.check_out
        if object.check_out.to_i > check_out
          errors.add(:check_out, :less_than_previous_value)
          throw(:abort)
        end
      end
    end

    def execute
      object.update(check_out: Time.at(check_out))
      errors.merge!(object.errors) if object.errors.any?
      if valid? && user = object.vehicle.user
        UserNotifier.time_extended(user, object)
      end
      Ai::Parking::OvertimeTickerWorker.extend_or_create(object)
    end
  end
end
