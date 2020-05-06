module Dashboard
  class ApplicationController < ::ApplicationController
    layout 'application'
    before_action :configure_permitted_parameters, if: :devise_controller?
    before_action :authenticate_admin!

    def env
      render json: ENV.to_json
    end

    protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_in, keys: [:login, :password, :password_confirmation])
    end

    private

    def after_sign_out_path_for(resource_or_scope)
      if resource_or_scope == :admin
        new_admin_session_path
      else
        root_path
      end
    end
  end
end
