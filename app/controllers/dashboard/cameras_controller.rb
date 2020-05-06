module Dashboard
  class CamerasController < AdministrateController
    before_action :convert_params, only: [:create, :update]

    def vmarkup
      send_data requested_resource.vmarkup.to_json, filename: :'camera.vmarkup',
                type: :json,
                disposition: :attachment
    end

    def create
      outcome = Cameras::Create.run(params[:camera])

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
      record = Camera.find(params[:id])
      outcome = Cameras::Update.run(params[:camera].merge(object: record))

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

    def convert_params
      payload = params.require(:camera).permit!

      if payload[:vmarkup].present?
        payload[:vmarkup] = Base64.encode64(payload[:vmarkup].read)
      end
    end
  end
end
