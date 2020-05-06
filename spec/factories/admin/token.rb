FactoryBot.define do
  factory :admin_token, class: Admin::Token do
    value { User::Token.generate }
    expired_at { User::Token::EXPIRE_PERIOD.from_now }
    admin
  end
end
