FactoryBot.define do
  factory :parking_session do
    t = Time.now
    vehicle
    parking_slot
    uuid { SecureRandom.hex(10) }
    parking_lot { self.parking_slot&.parking_lot }
    entered_at { t }
    check_in { t }
    check_out { t + 2.hours }

    trait :with_cash_payment do
      after :create do |session|
        FactoryBot.create(:payment, parking_session_id: session.id, payment_method: :cash)
      end
    end

  end
end
