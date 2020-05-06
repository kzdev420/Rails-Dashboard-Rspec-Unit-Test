module Api
  module V1
    class VehiclesController < ::Api::V1::ApplicationController
      # before_action :authenticate_user!, except: %i[verify]

      api :GET, '/api/v1/vehicles', 'Search vehicle by plate number'
      param :vehicle, Hash do
        param :user_associated, [0, 1], 'Indicates if the vehicle should have a user associated to it'
        param :plate_number, String, 'Vehicle id', required: true
      end
      header :Authorization, 'Auth token from users#sign_in', required: true

      def index
        result = ::Api::V1::VehiclesQuery.call(params.fetch(:vehicle, {}).merge(user: current_user))
        respond_with result, each_serializer: ::Api::V1::VehicleSerializer
      end

      api :POST, '/api/v1/vehicles', 'Create new user vehicle'
      param :vehicle, Hash do
        param :plate_number, String, required: true
        param :vehicle_type, String, required: false
        param :color, String, required: false
        param :manufacturer_id, Integer, required: false
        param :model, String, required: true
      end
      header :Authorization, 'Auth token from users#sign_in', required: true

      def create
        payload = params.fetch(:vehicle, {}).merge(user: current_user)
        result = ::Vehicles::Create.run(payload)
        respond_with result, serializer: ::Api::V1::VehicleSerializer
      end

      api :DELETE, '/api/v1/vehicles/:id', 'Delete vehicle from user account'
      param :id, String, 'Vehicle id', required: true
      header :Authorization, 'Auth token from users#sign_in', required: true

      def destroy
        vehicle = current_user.vehicles.find(params[:id])
        result = ::Vehicles::Delete.run(vehicle: vehicle)
        respond_with result
      end

      api :GET, '/api/v1/vehicles/verify', 'Verify if vehicle will be allowed to register'
      param :vehicle, Hash do
        param :plate_number, String, 'Vehicle id', required: true
      end

      def verify
        plate_number = (params.dig(:vehicle,:plate_number) || '').delete(' ')
        if plate_number.present?
          allowed = Vehicle.find_or_initialize_by(plate_number: plate_number).user_id == nil ? true : false
          message = I18n.t('active_interaction.errors.models.vehicles/create.attributes.base.already_taken_by_another_account', { plate_number: plate_number.upcase }) unless allowed
        else
          allowed = false
          message = I18n.t('activerecord.errors.models.vehicle.attributes.plate_number.invalid')
        end
        render json: {
          allowed: allowed,
          message: message
        }, status: 200
      end
    end
  end
end