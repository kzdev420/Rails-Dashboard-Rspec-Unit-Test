FactoryBot.define do
  factory :payment do
    parking_session
    amount { Faker::Number.decimal(2).to_f }
    status { Faker::Number.between(0, 2) }
    payment_method { Payment.payment_methods.values.sample }
    trait(:success) do
      status { :success }
    end
  end
end
