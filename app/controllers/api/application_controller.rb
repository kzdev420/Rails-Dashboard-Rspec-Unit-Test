module Api
  class ApplicationController < ::ApplicationController
    include ::Api::Errors
    include Rails::Pagination
    protect_from_forgery with: :null_session
    respond_to :json
    self.responder = ::ApiResponder

    private

    def per_page
      params[:per_page] || 10
    end

    def page
      params[:page]
    end

    def paginate(scope, **options)
      super(scope, { per_page: per_page, page: page }.merge(options))
    end

    def array_serializer
      ActiveModel::Serializer::CollectionSerializer
    end
  end
end
