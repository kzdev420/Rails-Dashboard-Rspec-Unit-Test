module Users
  class SendConfirmation

    def self.call(user)
      user.update_attributes(confirmation_sent_at: Time.zone.now)
      new_code = 6.times.map { rand.to_s.last }.join
      user.update_column(:confirmation_token, new_code)
      user.send_confirmation_instructions
    end

  end
end
