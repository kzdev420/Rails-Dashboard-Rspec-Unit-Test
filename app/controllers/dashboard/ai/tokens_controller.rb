module Dashboard
  module Ai
    class TokensController < AdministrateController
      include TokenActions
      token_klass ::Ai::Token
    end
  end
end
