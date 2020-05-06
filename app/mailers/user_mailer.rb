class UserMailer < Devise::Mailer
  helper :application # gives access to all helpers defined within `application_helper`.
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  default template_path: 'user_mailer' # to make sure that your mailer uses the devise views

  def confirmation_instructions(record, token, opts={})
    opts[:subject] = "Account Confirmation Code: #{token}"
    @first_name = record.first_name
    super
  end

  def reset_password_instructions(record, token, *args)
    @reset_password_url = "https://#{ENV['APP_DOMAIN']}#{ENV['USERS_RESET_PASSWORD_PATH']}/#{token}"
    super
  end

  def payment_receipt(user_id, session_id, amount, reference_id, payment_date, card_last_four_digits, card_network)
    @card_network = card_network
    @card_last_four_digits = card_last_four_digits
    @payment_date = payment_date.to_date
    @amount = amount
    @reference_id = reference_id
    @user = User.find(user_id)
    @parking_session = ParkingSession.find(session_id)
    mail(
      from: ENV['MAIL_FROM'],
      to: @user.email,
      subject: 'Park Smart Payment Confirmation'
    )
  end

  def password_change(*)
    super
  end
end
