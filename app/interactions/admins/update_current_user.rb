module Admins
  class UpdateCurrentUser < ::ApplicationInteraction

    object :current_user, class: Admin
    string :email
    string :username
    string :name
    string :old_password, default: nil
    string :password, default: nil
    string :phone, default: nil
    interface :avatar, default: nil # can be File or String
    boolean :delete_avatar, default: false

    set_callback :execute, :before, :set_previous_email

    validates :password, length: { minimum: 7, maximum: 50 }, if: :user_tries_to_change_password?

    validate do
      if user_tries_to_change_password?
        unless current_user.valid_password?(old_password)
          errors.add(:password, :invalid)
          throw(:abort)
        end
      end
    end

    def execute
      unless current_user.update(user_params)
        errors.merge!(current_user.errors)
      else
        AdminMailer.profile_updated(current_user).deliver_later
        if @previous_email != current_user.email
          AdminMailer.profile_email_changed(@previous_email, current_user.email).deliver_later
        end
      end
      self
    end

    def to_model
      current_user.reload
    end

    private

    def user_tries_to_change_password?
      password.present?
    end

    def user_params
      data = inputs.slice(:email, :username, :phone, :name)
      data[:password] = password if user_tries_to_change_password?
      data[:avatar] = { data: inputs[:avatar] } if inputs[:avatar].present?
      data
    end

    def set_previous_email
      @previous_email = current_user.email
    end

  end
end
