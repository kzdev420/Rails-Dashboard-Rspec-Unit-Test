class Authorizer
  class << self
    def generate_token(owner)
      token_class = owner.tokens.model
      token_value = token_class.generate
      owner.tokens.create!(
        expired_at: token_class::EXPIRE_PERIOD.from_now,
        value: token_class.encrypt(token_value)
      )
      remove_stale_tokens(owner.tokens, owner.tokens.model::MAX_COUNT)
      "#{owner.id}:#{token_value}"
    end

    def authorize_by_token(token, klass)
      return nil unless token.present? && token.is_a?(String)
      id, auth_token = token.split(':')[0], token.split(':')[1]
      return nil unless id && auth_token
      user = klass.find_by(id: id)
      return nil unless user
      if user.find_by_token(auth_token)
        user
      end
    end

    private

    def remove_stale_tokens(tokens, max)
      return if tokens.count <= max
      persisted = tokens.select(:id).order(expired_at: :desc).first(max)
      tokens.where.not(id: persisted).destroy_all
    end
  end
end
