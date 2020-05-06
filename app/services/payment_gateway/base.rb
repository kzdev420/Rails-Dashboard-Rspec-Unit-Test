
module PaymentGateway
  class Base
    include ApplicationHelper

    def initialize(payment_info, parking_session, params)
      @payment_info = payment_info
      @parking_session = parking_session
      @params = params
    end

    def pay!
      charge_customer
    end

    def write_logs(message)
      filename_path = "#{Rails.root}/log/payments_errors.log"
      logger = Logger.new(filename_path)
      logger.info("Parking Session ID: #{parking_session.id}, Message: #{message}")
    end

    def customer
      @parking_session.user
    end

    def amount
      @payment_info.unpaid
    end

    def parking_session
      @parking_session
    end

    def card_network
      return '' unless credit_card.present?
      CreditCardValidations::Detector.new(credit_card['number'])&.brand&.to_s
    end

    def credit_card
      return @credit_card if @credit_card.present?

      if @params[:credit_card_id].blank?
        @credit_card = @params[:credit_card_attributes]
      else
        @credit_card = customer.credit_cards.find(@params[:credit_card_id])
      end
    rescue Exception => e
      raise ::Payments::StandardError, 'Credit Card Invalid, please contact support for further information or try to add your credit card again'
    end

    def store_credit_card
      if @params[:credit_card_id].present? && set_credit_card_as_default?
        return customer.update(default_credit_card_id: @params[:credit_card_id])
      end

      credit_card_attributes = @params[:credit_card_attributes]
      if credit_card_attributes.present? && credit_card_attributes[:should_store].to_s == '1'
        new_credit_card = customer.credit_cards.create(credit_card_params)
        # Store credit card if the user explicitly state that he wants it as the default one or if it's the first one associated to the account
        customer.update(default_credit_card_id: new_credit_card.id) if set_credit_card_as_default? || customer.credit_cards.count == 1
      end
    end

    def set_payment_receipt_message(reference_id, card_last_four_digits)
      locales_key = "activerecord.models.message.templates.invoice_text"

      message_text = I18n.t(locales_key, {
        user_first_name: customer.first_name,
        parking_session_id: parking_session.id,
        amount: amount / 100.to_f,
        reference_id: reference_id,
        card_network: card_network,
        payment_details_date: formatted_datetime(DateTime.current),
        card_last_four_digits: card_last_four_digits
      })
      message = customer.messages.create!(template: :invoice, text: message_text, to: customer)
      User::PushNotificationToken.send_message(customer, message)
    end

    def credit_card_params
      @params[:credit_card_attributes].slice(:number, :holder_name, :expiration_year, :expiration_month)
    end

    def set_credit_card_as_default?
      @params[:set_credit_card_as_default].to_s == '1'
    end
  end
end
