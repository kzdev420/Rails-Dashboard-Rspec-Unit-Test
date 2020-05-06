module Dashboard
  class ParkingLotsController < AdministrateController
    before_action :convert_params, only: [:create, :update]

    def reset_sessions
      lot = ParkingLot.find(params[:id])
      if lot.parking_sessions.any?
        lot.parking_slots.update_all(status: :free)
        lot.parking_sessions.update_all(status: :finished)
      end
      redirect_to dashboard_parking_lot_path(lot)
    end

    def outline
      send_data requested_resource.outline.to_json, filename: :'outline.parking',
                type: :json,
                disposition: :attachment
    end

    def create
      outcome = ParkingLots::Create.run(params[:parking_lot])

      if outcome.object
        redirect_to(
          [namespace, outcome.object],
          notice: translate_with_resource("create.success")
        )
      else
        flash.now[:error] = outcome.errors.messages.values.flatten.join('</br>')
        render :new, locals: {
          page: Administrate::Page::Form.new(dashboard, resource_class.new(resource_params)),
        }
      end
    end

    def update
      record = ParkingLot.find(params[:id])
      outcome = ParkingLots::UpdateOutline.run({ object: record, outline: generate_outline })

      if outcome.valid?
        redirect_to(
          [namespace, outcome.object],
          notice: translate_with_resource("update.success"),
          )
      else
        flash.now[:error] = outcome.errors.messages.values.flatten.join('</br>')
        render :edit, locals: {
          page: Administrate::Page::Form.new(dashboard, outcome.object),
        }
      end
    end

    private

    def order
      @order ||= Administrate::Order.new(
        params.fetch(resource_name, {}).fetch(:order, 'created_at'),
        params.fetch(resource_name, {}).fetch(:direction, 'asc'),
      )
    end

    def generate_outline
      payload = params.require(:parking_lot).permit!

      if payload[:outline].present?
        payload[:outline]
      end
    end

    def convert_params
      payload = params.require(:parking_lot).permit!

      if payload[:outline].present?
        payload[:outline] = Base64.encode64(payload[:outline].read)
      end

      payload[:setting] = payload[:setting_attributes]
      payload[:location] = payload[:location_attributes]
      payload[:parking_admin_id] = payload[:parking_admin]
      payload[:town_manager_id] = payload[:town_manager]
    end
  end
end
