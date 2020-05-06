# ValueObject for parking time calculations
# See reference in ParkingSession, eg. #payment_info

class PaymentInfo < Struct.new(:session)
  delegate :rate,
           :fee_applied, # Once parking session is confirmed this should be the fee instead of the rate fee
           :period,
           :check_in,
           :check_out,
           :payments,
           :free, # free seconds that user can stay without paying
           to: :session

  def paid
    # 0 - means that there are no successful payments.
    return 0 if amount.blank? || amount.zero?
    amount.to_i
  end

  def unpaid
    return 0 if check_in.blank? # It didn't parked
    return -1 if check_out.blank?
    debt = pay - paid
    return 0 if debt <= 0 # It's already paid
    debt.to_i
  end

  def paid?
    unpaid.zero?
  end

  # The result is in cents
  # Use to get the total charged to the user
  def pay
    return -1 if check_out.blank?
    time_stayed = check_out.to_i - check_in.to_i
    return ((rate / (::ParkingLot::PERIOD_NORMALIZER.to_f / period)) * 100).to_i if time_stayed <= period
    ((time_stayed / ::ParkingLot::PERIOD_NORMALIZER.to_f) * (fee_applied || rate) * 100).to_i
  end

  def amount
    @amount ||= payments.success.sum(:amount)
  end
end
