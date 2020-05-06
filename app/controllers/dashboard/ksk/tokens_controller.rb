module Dashboard
  module Ksk
    class TokensController < AdministrateController
      include TokenActions
      token_klass ::Ksk::Token

      def seed
        Build::DatabaseBuilder.run
        redirect_to dashboard_ksk_tokens_path
      end
    end
  end
end
