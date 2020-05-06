class AdminMailer < Devise::Mailer
  helper :application # gives access to all helpers defined within `application_helper`.
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  default template_path: 'admin_mailer' # to make sure that your mailer uses the devise views
  default from: ENV['MAIL_FROM']

  def reset_password_instructions(record, token, *args)
    @reset_password_url = "#{ENV['DASHBOARD_DOMAIN']}#{ENV['ADMINS_RESET_PASSWORD_PATH']}/#{token}"
    super
  end

  def password_change(*)
    super
  end

  def welcome_letter(user, password)
    @user = user
    @password = password
    @email = user.email
    mail to: @email
  end

  def user_created(subject, user)
    @user = subject
    @email = user.email
    mail to: @email
  end

  def profile_email_changed(previous_email, new_email)
    @previous_email = previous_email
    @new_email = new_email
    mail(to: @previous_email,
         template_path: 'admin_mailer')
  end

  def profile_updated(user)
    @user = user
    @email = user.email
    mail(to: @email,
         template_path: 'admin_mailer')
  end

  def subject_created(*args)
    subject_notification(*args)
  end

  def subject_updated(*args)
    subject_notification(*args)
  end

  def assigned_to_agency(agency_id, admin_id)
    subject_notification(Agency.find(agency_id), Admin.find(admin_id))
  end

  def unassigned_from_agency(agency_id, admin_id)
    subject_notification(Agency.find(agency_id), Admin.find(admin_id))
  end

  def assigned_to_dispute(dispute_id, admin_id)
    subject_notification(Dispute.find(dispute_id), Admin.find(admin_id))
  end

  def assigned_to_parking_lot(parking_lot_id, admin_id)
    subject_notification(ParkingLot.find(parking_lot_id), Admin.find(admin_id))
  end

  def unassigned_from_parking_lot(parking_lot_id, admin_id)
    subject_notification(ParkingLot.find(parking_lot_id), Admin.find(admin_id))
  end

  private

  def subject_notification(subject, user_to_notify)
    @subject = subject
    @subject_type = subject.class.model_name.human.downcase
    @email = user_to_notify.email
    mail(to: @email,
         template_path: 'admin_mailer',
         template_name: 'subject_notification')
  end
end
