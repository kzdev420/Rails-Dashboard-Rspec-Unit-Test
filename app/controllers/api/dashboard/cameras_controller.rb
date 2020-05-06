module Api
  module Dashboard
    class CamerasController < ApplicationController
      api :GET, '/api/dashboard/cameras', 'List of cameras'
      header :Authorization, 'Auth token', required: true
      param :per_page, Integer, 'Items per page count, default is 10. Check response headers for total count (key: X-Total)'
      param :page, Integer, 'Items page number'
      param :parking_lot_id, Integer, 'Parking lot id', required: true
      param :name, String, "Camera name to be searched", required: false
      param :order, Hash, 'Hash order' do
        param :keyword, Camera.attribute_names.reject { |n| n == 'password' }, "Username for login", required: false
        param :direction, ['asc', 'desc'], "Order Direction", required: false
      end

      def index
        authorize!
        scope = CamerasIndexQuery.call(params.merge(user: current_user))
        respond_with paginate(scope), each_serializer: CameraSerializer
      end

      api :GET, '/api/dashboard/cameras/:id', 'Camera details'
      header :Authorization, 'Auth token', required: true

      def show
        camera = Camera.find(params[:id])
        authorize! camera
        respond_with camera, serializer: CameraSerializer
      end

      api :POST, '/api/dashboard/cameras', 'Adds new camera'
      header :Authorization, 'Auth token', required: true
      param :camera, Hash, required: true do
        param :stream, URI.regexp, 'Valid rtsp stream', required: true
        param :name, String, 'Name of the device'
        param :vmakrup, String, 'Json'
        param :login, String, 'Username for the stream endpoint'
        param :password, String, 'Password for the stream endpoint'
        param :other_information, String, 'Additional data related to the camera'
        param :parking_lot_id, Integer, 'Parking lot id', required: true
      end

      def create
        authorize!
        result = Cameras::Create.run(params[:camera])
        respond_with result, serializer: CameraSerializer
      end

      api :PUT, '/api/dashboard/cameras/:id', 'Updates camera'
      header :Authorization, 'Auth token', required: true
      param :camera, Hash do
        param :stream, URI.regexp, 'Valid rtsp stream'
        param :name, String, 'Name of the device'
        param :vmakrup, String, 'Json'
        param :login, String, 'Username for the stream endpoint'
        param :password, String, 'Password for the stream endpoint'
        param :allowed, [0, 1], '0 means is not allowed and 1 allowed to every role'
        param :parking_lot_id, Integer, 'Parking lot id'
        param :other_information, String, 'Additional data related to the camera'
      end

      def update
        camera = Camera.find(params[:id])
        authorize! camera
        payload = params.fetch(:camera, {}).merge(object: camera)
        result = Cameras::Update.run(payload)
        respond_with result, serializer: CameraSerializer
      end

      private

      def per_page
        params[:per_page] || 20
      end

    end
  end
end
