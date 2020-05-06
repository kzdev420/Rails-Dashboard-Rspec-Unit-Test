FactoryBot.define do
  factory :parking_ticket_log, class: 'Parking::Ticket::Log' do
    association :ticket, factory: :parking_ticket
  end
end
