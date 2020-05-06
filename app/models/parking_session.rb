##
# Model to handle each parking session, these sessions start when the AI detects a car on any of the following events:
# - Car Entrance
# - Car Park
# - Car Exit
# ## Table's Columns
# - check_in => [datetime] Indicate DateTime when the car parked
# - check_out => [datetime] Indicate DateTime when the car should leave or leave
# - parking_slot_id => [bigint] Reference ID to a {ParkingSlot parking slot}
# - vehicle_id => [bigint] Reference ID to a {Vehicle vehicle}
# - kiosk_id => [bigint]  Reference ID to a {Kiosk kiosk}
# - parking_lot_id => [integer] Reference ID to a {ParkingLot parking lot}
# - status => [integer] Status can be created, confirmed, finished, cancelled
# - entered_at => [datetime] Indicate DateTime when the car parked at car_entrance.rb
# - exit_at => [datetime]  Indicate DateTime when the car parked at car_exit.rb
# - parked_at => [datetime] Indicate DateTime when the car parked at car_parked.rb
# - left_at => [datetime] Indicate DateTime when the car left a parking slot at car_left.rb
# - uuid => [string] Unique identifier for each parking session created automatically by the AI
# - ai_status => [integer] Last status sent by the AI
# - fee_applied => [float] This attribute is set when a session is confirmed and paid
# - created_at => [datetime]
# - updated_at => [datetime]

class ParkingSession < ApplicationRecord
  include ActiveStorageSupport::SupportForBase64
  include SpreadsheetArchitect

  # If session has parking lot, but it doesn't have parking slot
  # it means that car has already entered parking lot, but hasn't occupied parking slot yet
  belongs_to :parking_slot, optional: true
  belongs_to :parking_lot
  belongs_to :kiosk, optional: true
  belongs_to :vehicle
  has_one :user, through: :vehicle

  has_paper_trail ignore: [:updated_at], versions: {
    scope: -> { order("id desc") },
    name: :logs
  }

  has_many_base64_attached :images

  with_options dependent: :destroy do |assoc|
    assoc.has_many :violations, class_name: 'Parking::Violation', foreign_key: :session_id
    assoc.has_many :user_notifications, class_name: 'User::Notification'
    assoc.has_one :dispute
    assoc.has_many :alerts, as: :subject
    assoc.has_many :payments
    assoc.has_many :tickets, class_name: "Parking::Ticket", through: :violations, source: :ticket
  end

  validates :uuid, presence: true, uniqueness: true

  enum status: [:created, :confirmed, :finished, :cancelled]

  enum ai_status: {
    entered: 0,
    parked: 1,
    left: 2,
    exited: 3
  }
  scope :with_preloaded, -> { includes(vehicle: :user, parking_slot: [parking_lot: :setting]) }
  scope :current, -> { where(status: [:created, :confirmed]).where.not(check_in: nil, check_out: nil) }

  delegate :paid?, to: :payment_info
  alias :paid :paid?

  SETTINGS = [:period, :rate, :overtime, :parked, :free].freeze

  SPREADSHEET_OPTIONS = {
    sheet_name: 'Transaction Records'.freeze
  }

  # @return {PayementInfo payment info}
  def payment_info
    PaymentInfo.new(self)
  end

  def method_missing(name, *args, &block)
    case name
    when *SETTINGS
      delegate_setting(name)
    else
      super
    end
  end

  # @return Array used to generate a excel document with the session details
  def spreadsheet_columns

    serialized = Api::Dashboard::Parking::SessionSerializer.new(self).attributes

    ### Column format is: [Header, Cell Data / Method (if symbol) to Call on each Instance, (optional) Cell Type]
    [
      ['Transaction number', :id],
      ['Vehicle Plate', vehicle&.plate_number],
      ['Account Linked', serialized[:user_id]],
      ['Kiosk Number', :kiosk_id],
      ['Date', :created_at],
      ['Start', :check_in],
      ['End', :check_out],
      ['Parking Space ID', serialized[:slot].present? ? serialized[:slot][:id] : '' ],
      ['Parking Fee', serialized[:fee_applied]],
      ['Total Fee', serialized[:total_price]],
      ['Payment Status', serialized[:paid] ],
      ['Parking Session Status', serialized[:status]],
      ['Payment Method', serialized[:payments].map(&:payment_method).join(",")]
    ]
  end

  private

  def delegate_setting(setting)
    if parking_slot_id && parking_slot&.zone&.setting
      parking_slot.zone.send(setting)
    else
      parking_lot.send(setting)
    end
  end
end
