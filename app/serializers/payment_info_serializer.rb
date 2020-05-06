class PaymentInfoSerializer < ApplicationSerializer
  attributes :total_time, :rate, :paid_time, :unpaid_time, :total_amount

  def total_time
    if object.check_out
      object.check_out.to_i - object.check_in.to_i
    end
  end

  def rate
    payment_info.rate
  end

  def paid_time
    payment_info.paid
  end

  def unpaid_time
    payment_info.unpaid
  end

  def total_amount
    payment_info.pay
  end

  def payment_info
    @payment_info ||= object.payment_info
  end

  private :payment_info
end
