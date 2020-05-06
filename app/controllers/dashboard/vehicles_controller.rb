module Dashboard
  class VehiclesController < AdministrateController
    def search
      if params[:search].present?
        if params[:accuarate] == "1"
          resources = scoped_resource.where(plate_number: params[:search]) if params[:search].present?
        else
          resources = scoped_resource.where("plate_number ilike ?", "%#{params[:search]}%") if params[:search].present?
        end
      else
        resources = scoped_resource
      end
      resources = apply_resource_includes(resources)
      resources = order.apply(resources)
      resources = resources.page(params[:page]).per(records_per_page)
      page = Administrate::Page::Collection.new(dashboard, order: order)
      render :index, locals: {
        resources: resources,
        search_term: '',
        page: page,
        show_search_bar: show_search_bar?,
      }
    end

    def reset_sessions
      vehicle = Vehicle.find(params[:id])
      if vehicle.parking_sessions.any?
        ParkingSlot.where(id: vehicle.parking_sessions.map(&:parking_slot)).update_all(status: :free)
        vehicle.parking_sessions.update_all(status: :finished)
      end
      redirect_to dashboard_vehicle_path(vehicle)
    end

    def valid_action?(name, resource = resource_class)
      %w[destroy].exclude?(name.to_s) && super
    end

  end
end
