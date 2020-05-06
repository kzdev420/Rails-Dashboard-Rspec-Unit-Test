class ViolationMailer < ApplicationMailer
  def commited(email, violation_id)
    @email = email
    @violation = Parking::Violation.find(violation_id)
    mail to: email
  end
end
