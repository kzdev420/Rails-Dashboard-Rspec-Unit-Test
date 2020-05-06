##
# Model to handle payments for a parking session (a {ParkingSession parking session} can have multiple payments)
# ## Table's Columns
# - amount => [decimal] Amount in cent paid by the user
# - parking_session_id => [integer] Reference ID to a {ParkingSession parking session}
# - status => [integer] Indicates if the status was succeful or failed (currentl pending is not used)
# - payment_method => [string] How the user paid credit_card, cash or if it was a free
# - payment_gateway => [string] which payment gateway processed the payment
# - meta_data => [json] extra data returned by the payment gateway that might nbe useful to debug
# - created_at => [datetime]
# - updated_at => [datetime]
class Payment < ApplicationRecord
  belongs_to :parking_session
  has_one :parking_lot, through: :parking_session

  enum payment_method: [:cash, :credit_card, :free_pay] # Free payment it should happen if the parking lot hourly rate is 0 (It's not implement yet)

  enum status: {
    failed: 0,
    pending: 1,
    success: 2
  }

end
