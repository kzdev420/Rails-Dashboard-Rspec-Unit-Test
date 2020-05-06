module Dashboard
  class AdministrateController < Administrate::ApplicationController
    layout :layout_by_resource
    before_action :authenticate_admin!
    before_action :order

    def order
      @order ||= Administrate::Order.new(
        params.fetch(resource_name, {}).fetch(:order, 'created_at'),
        params.fetch(resource_name, {}).fetch(:direction, 'desc'),
      )
    end

    private

    def layout_by_resource
      if devise_controller?
        'devise'
      else
        'application'
      end
    end
  end
end
