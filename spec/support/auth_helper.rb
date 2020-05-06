module AuthHelper
  def get_auth_token(owner)
    Authorizer.generate_token(owner)
  end
end
