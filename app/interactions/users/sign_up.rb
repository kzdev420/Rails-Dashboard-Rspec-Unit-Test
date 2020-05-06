module Users
  class SignUp < ApplicationInteraction
    attr_reader :user

    string :email
    string :password
    string :first_name
    string :last_name
    string :phone
    array :vehicles, default: nil
    interface :avatar, default: nil # can be File or String

    set_callback :execute, :after, :confirm, if: :valid?

    validates :vehicles, presence: true

    def execute
      ActiveRecord::Base.transaction do
        save_user
        save_vehicles
      end
      self
    end

    private

    def save_user
      @user = User.new(user_params)
      user.skip_confirmation!
      unless user.save
        errors.merge!(user.errors)
        raise ActiveRecord::Rollback
      end
    end

    def save_vehicles
      inputs[:vehicles]&.each do |vehicle_attr|
        transactional_compose!(::Vehicles::Create, vehicle_params(vehicle_attr).merge(user: user))
      end
    end

    def vehicle_params(attr)
      attr.symbolize_keys.slice(:plate_number, :vehicle_type, :manufacturer_id, :model, :color)
    end

    def confirm
      user.update_attributes(confirmed_at: nil)
      Users::SendConfirmation.call(user) if valid?
    end

    def user_params
      data = inputs.slice(:email, :password, :first_name, :last_name, :phone)
      data[:avatar] = { data: inputs[:avatar] } if inputs[:avatar].present?
      data
    end
  end
end
