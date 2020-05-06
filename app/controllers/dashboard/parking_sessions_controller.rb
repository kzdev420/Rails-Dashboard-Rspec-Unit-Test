module Dashboard
  class ParkingSessionsController < AdministrateController
    def search
      resources = scoped_resource.where(parking_lot_id: params[:search][:lot_id]) if params[:search][:uuid].blank?
      resources = scoped_resource.where(uuid: params[:search][:uuid]) if params[:search][:uuid].present?
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

    def reset_session
      session = ParkingSession.find(params[:id])
      if session.status != 'finished'
        session.parking_slot.update(status: :free)
        session.update(status: :finished)
      end
      redirect_to dashboard_parking_session_path(session)
    end

  end
end
