module Admins
  class Base < ::ApplicationInteraction
    object :current_user, class: Admin

    validates :status, inclusion: Admin.statuses.keys, if: -> { status.present? }

    def to_model
      user.reload
    end

    private

    def user_params
      data = inputs.slice(:email, :status, :username, :phone, :role_id, :name)
      data[:avatar] = { data: inputs[:avatar] } if inputs[:avatar].present?
      data
    end
  end
end
