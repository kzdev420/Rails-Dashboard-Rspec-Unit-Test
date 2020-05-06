class AdminMailerPreview < ActionMailer::Preview

  # Accessible from http://localhost:3000/rails/mailers/admin_mailer/reset_password_instructions
  def reset_password_instructions
    user = Admin.new(email: 'test@test.com')
    AdminMailer.reset_password_instructions(user, '12345678', {})
  end

  # Accessible from http://localhost:3000/rails/mailers/admin_mailer/password_change
  def password_change
    user = Admin.new(email: 'test@test.com')
    AdminMailer.password_change(user, {})
  end

  # Accessible from http://localhost:3000/rails/mailers/admin_mailer/user_created
  def user_created
    user = Admin.new(email: 'new_admin@gmail.com', username: 'test', name: 'John', role: Role.first)
    AdminMailer.user_created(user, admin)
  end

  # Accessible from http://localhost:3000/rails/mailers/admin_mailer/welcome_letter
  def welcome_letter
    user, password = Admin.new(email: 'new_admin@gmail.com', name: 'John'), '12345678'
    AdminMailer.welcome_letter(user, password)
  end

  # Accessible from http://localhost:3000/rails/mailers/admin_mailer/profile_updated
  def profile_updated
    user, password = Admin.new(email: 'new_admin@gmail.com', name: 'John'), '12345678'
    AdminMailer.profile_updated(user)
  end

  # Accessible from http://localhost:3000/rails/mailers/admin_mailer/profile_email_changed
  def profile_email_changed
    AdminMailer.profile_email_changed('old_admin@gmail.com', 'new_admin@gmail.com')
  end

  # Accessible from http://localhost:3000/rails/mailers/admin_mailer/subject_created
  def subject_created
    AdminMailer.subject_created(subject, admin)
  end

  # Accessible from http://localhost:3000/rails/mailers/admin_mailer/subject_updated
  def subject_updated
    AdminMailer.subject_updated(subject, admin)
  end

  # Accessible from http://localhost:3000/rails/mailers/admin_mailer/assigned_to_agency
  def assigned_to_agency
    AdminMailer.assigned_to_agency(agency.id, admin.id)
  end

  # Accessible from http://localhost:3000/rails/mailers/admin_mailer/unassigned_from_agency
  def unassigned_from_agency
    AdminMailer.unassigned_from_agency(agency.id, admin.id)
  end

  def assigned_to_dispute
    AdminMailer.assigned_to_dispute(dispute.id, admin.id)
  end

  def assigned_to_parking_lot
    AdminMailer.assigned_to_parking_lot(parking_lot.id, admin.id)
  end

  def unassigned_from_parking_lot
    AdminMailer.unassigned_from_parking_lot(parking_lot.id, admin.id)
  end

  private

  def admin
    Admin.first
  end

  def agency
    Agency.first_or_initialize(name: 'Awesome name')
  end

  def dispute
    Dispute.first_or_initialize
  end

  def parking_lot
    ParkingLot.first_or_initialize(name: 'Awesome name')
  end

  def subject
    [Agency, ParkingLot].sample.first_or_initialize(name: 'Awesome name')
  end
end
