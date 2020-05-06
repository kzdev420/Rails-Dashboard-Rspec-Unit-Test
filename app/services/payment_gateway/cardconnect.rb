
# frozen_string_literal: true
# Test Documentation: https://developer.cardconnect.com/guides/cardpointe-gateway
module PaymentGateway
  class Cardconnect < Base

    DATA = {
      test: {
        site: ENV['CARDCONNECT_SITE_TEST'],
        merchant_id: ENV['CARDCONNECT_MERCHANT_ID_TEST'],
        user: ENV['CARDCONNECT_USER_TEST'],
        password: ENV['CARDCONNECT_PASSWORD_TEST']
      },
      production: {
        site: ENV['CARDCONNECT_SITE_PRODUCTION'],
        merchant_id: ENV['CARDCONNECT_MERCHANT_ID_PRODUCTION'],
        user: ENV['CARDCONNECT_USER_PRODUCTION'],
        password: ENV['CARDCONNECT_PASSWORD_PRODUCTION']
      }
    }

    def rest_auth_url
      "https://#{DATA[env_key][:site]}.cardconnect.com/cardconnect/rest/auth"
    end

    def tokenize_url
      "https://#{DATA[env_key][:site]}.cardconnect.com/cardsecure/api/v1/ccn/tokenize"
    end

    def env_key
      @params[:production].to_s == '1' ? :production : :test
    end

    def charge_customer
      @token = tokenize_card

      # Check if payment is done via Apple Pay
      encryptionhandler = using_digital_wallet? ? @params[:digital_wallet_attributes][:encryptionhandler] : ''
      if (encryptionhandler == 'EC_APPLE_PAY')
        card_last_four_digits = @params[:last_credit_card_digits]
      else
        card_last_four_digits = @token.last(4)
      end
      
      json_params = using_digital_wallet? ? digital_wallet_charge_params : charge_params
      response = HTTP.basic_auth(user: DATA[env_key][:user], pass: DATA[env_key][:password]).post(rest_auth_url, { json: json_params })
      # respstat possible values
      # A - Approved
      # B - Retry
      # C - Declined
      case response.parse['respstat']
      when 'A'
        store_credit_card
        send_payment_receipt(response.parse['retref'], card_last_four_digits)
        set_payment_receipt_message(response.parse['retref'], card_last_four_digits)
        parking_session.payments.create(amount: amount, status: :success, payment_method: :credit_card, meta_data: response.parse, card_last_four_digits: card_last_four_digits)
      when 'B', 'C'
        parking_session.payments.create(amount: amount, status: :failed, payment_method: :credit_card, meta_data: response.parse, card_last_four_digits: card_last_four_digits)
        raise ::Payments::StandardError, "Something went wrong on the payment process. Reason: #{response.parse['resptext']}"
      end
    end

    private

    def tokenize_card
      # Search or accept a new card
      if using_digital_wallet?
        options = {
          json: {
            encryptionhandler: @params.dig('digital_wallet_attributes', 'encryptionhandler'),
            devicedata: @params.dig('digital_wallet_attributes', 'devicedata')
          }
        }
      else
        options = {
          json: {
            account: credit_card['number']
          }
        }
      end
      response = HTTP.post(tokenize_url, options)
      error_code = response.parse.dig('errorcode')
      if error_code.to_s == '0'
        response.parse.dig('token')
      else
        write_logs(response.parse)
        raise ::Payments::StandardError, 'Something went wrong during the token request'
      end
    end

    def digital_wallet_charge_params
      {
        "merchid": DATA[env_key][:merchant_id],
        "account": @token,
        "amount": amount,
        "currency": "USD",
        "email": customer.email,
        "capture": "y",
        "receipt": "y"
      }
    end

    def charge_params
      {
        "merchid": DATA[env_key][:merchant_id],
        "account": @token,
        "expiry": "#{credit_card[:expiration_month].to_s.rjust(2, '0')}#{credit_card[:expiration_year]}",
        "cvv2":  @params[:credit_card_attributes][:cvv],
        "amount": amount,
        "currency": "USD",
        "name": credit_card[:holder_name],
        "email": customer.email,
        "capture": "y",
        "receipt": "y"
      }
    end

    def using_digital_wallet?
      @params[:digital_wallet_attributes].present?
    end

    def send_payment_receipt(reference_id, card_last_four_digits)
      UserMailer.payment_receipt(customer.id, parking_session.id, amount, reference_id, DateTime.current.to_s, card_last_four_digits, card_network).deliver_later
    end

  end
end
