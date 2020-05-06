module Api
  module Ksk
    module Errors
      extend ActiveSupport::Concern
      included do
        def session_not_found!
          render json: { error: t('api.errors.ksk.session_not_found') }, status: 404
        end

        def session_with_ticket!(violation_name)
          render json: { error: t("api.errors.ksk.session_with_ticket.#{violation_name}",
                                  default: t('api.errors.ksk.session_with_ticket.base')
                                ),
                       }, status: 422
        end
      end
    end
  end
end
