FactoryBot.define do
  factory :user_token, class: User::Token do
    value { User::Token.generate }
    expired_at { User::Token::EXPIRE_PERIOD.from_now }
    user
  end
end
