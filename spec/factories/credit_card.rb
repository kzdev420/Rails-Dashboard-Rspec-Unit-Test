FactoryBot.define do
  factory :credit_card do
    number { ['4242424242424242', '4000056655665556', '5555555555554444', '2223003122003222'].sample }
    holder_name { Faker::Name.name }
    expiration_year { Faker::Number.between(21, 28) }
    expiration_month { Faker::Number.between(1, 12) }
  end
end
