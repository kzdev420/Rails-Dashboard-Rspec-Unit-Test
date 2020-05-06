namespace :parking_sessions do
  task check_expired: [:environment] do
    ParkingSessions::CheckExpired.call
  end
end
