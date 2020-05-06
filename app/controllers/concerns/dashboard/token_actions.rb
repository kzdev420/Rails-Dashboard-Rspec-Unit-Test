module Dashboard
  module TokenActions
    extend ActiveSupport::Concern

    included do
      extend ClassMethods
    end

    def index
      @tokens = token_klass.order(id: :desc)
    end

    def create
      token_klass.create!(token_params.merge(value: SecureRandom.hex(40)))
      redirect_back(fallback_location: root_path)
    end

    def destroy
      token = token_klass.find(params[:id])
      token.destroy
      redirect_back(fallback_location: root_path)
    end

    def token_params
      params.require(:token).permit!
    end

    private :token_params

    module ClassMethods
      def token_klass(klass)
        define_method :token_klass do
          klass
        end
      end
    end
  end
end
