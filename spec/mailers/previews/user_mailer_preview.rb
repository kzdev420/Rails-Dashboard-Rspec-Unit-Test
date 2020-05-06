class UserMailerPreview < ActionMailer::Preview

  # Accessible from http://localhost:3000/rails/mailers/user_mailer/reset_password_instructions
  def reset_password_instructions
    user = User.new(first_name: 'John', email: 'test@test.com')
    UserMailer.reset_password_instructions(user, '12345678', {})
  end

  # Accessible from http://localhost:3000/rails/mailers/user_mailer/confirmation_instructions
  def confirmation_instructions
    user = User.new(email: 'test@test.com', first_name: 'John')
    UserMailer.confirmation_instructions(user, '12345678', {})
  end

  # Accessible from http://localhost:3000/rails/mailers/user_mailer/password_change
  def password_change
    user = User.new(first_name: 'John')
    UserMailer.password_change(user, {})
  end

  # Accessible from http://localhost:3000/rails/mailers/user_mailer/payment_receipt
  def payment_receipt
    session_id = ParkingSession.last.id
    user_id = User.last.id
    amount = 250
    reference_id = 'TESTABC123'
    UserMailer.payment_receipt(user_id, session_id, amount, reference_id, DateTime.current.to_s, '4411', 'Visa')
  end

end
