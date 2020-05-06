#
# File concern to find valid token sent by the user
module TokenAuthorizable
  # @return [Admin::Token or User::Token] if token is not expired
  def find_by_token(token)
    tokens.not_expired.find_by(value: tokens.model.encrypt(token))
  end
end
