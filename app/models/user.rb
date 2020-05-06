#
# This model is to handle User registered using the Smart Parking App application
# ## Table's Columns
# - default_credit_card_id => [integer] {CreditCard credit card} that will be used by defualt on the payment form
# - avatar => [string] Profile Picture
# - first_name => [string]
# - last_name => [string]
# - phone => [string]
# - email => [string]
# - birthday => [date]
# - trackers => [Array] array of string to store all tracker ID used by a user
# - encrypted_password => [string]
# - reset_password_token => [string]
# - reset_password_sent_at => [datetime]
# - confirmation_token => [string]
# - confirmed_at => [datetime]
# - confirmation_sent_at => [datetime]
# - created_at => [datetime]
# - updated_at => [datetime]

class User < ApplicationRecord
  include TokenAuthorizable
  include ActiveStorageSupport::SupportForBase64

  devise :database_authenticatable, :registerable,
    :recoverable, :validatable, :confirmable

  acts_as_addressable billing: { presence: false }, shipping: { presence: false }
  has_many :addresses, -> { order(:updated_at) }, as: :addressable, class_name: 'Address', dependent: :delete_all, autosave: true

  has_many :tokens, class_name: 'User::Token', dependent: :destroy
  has_many :vehicles, dependent: :nullify
  has_many :notifications, dependent: :destroy
  has_many :active_vehicles, -> { where(status: :active) }, class_name: 'Vehicle'
  has_many :parking_sessions, through: :vehicles, source: :parking_sessions
  has_many :disputes, dependent: :destroy
  has_many :messages, as: :author, dependent: :destroy
  has_many :alerts, dependent: :destroy
  has_many :credit_cards, dependent: :destroy
  has_many :payments, through: :parking_sessions
  belongs_to :default_credit_card, class_name: 'CreditCard', optional: true

  validates :first_name, :last_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :email, presence: true, uniqueness: true
  validates :phone, phony_plausible: true, presence: true
  validate :old_enough?, if: -> { birthday.present? }
  phony_normalize :phone, default_country_code: 'US'
  accepts_nested_attributes_for :credit_cards

  has_one_base64_attached :avatar
  validates :avatar, size: { less_than: 10.megabytes , message: 'Your image is too large, max image size is 10mb' }

  VEHICLES_MAX_COUNT = 15

  def devise_mailer
    UserMailer
  end

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def password_token_valid?
    (reset_password_sent_at + 8.hours) > Time.now.utc
  end

  def old_enough?
    errors.add(:birthday, :invalid) if (birthday + 18.years) > Date.today
  end

  def avatar_thumbnail
    avatar.variant(resize: '250x250').processed
  rescue Errno::ENOENT # In case the image was deleted directly on the server
    avatar.purge # Remove association because it doesn't exist
    nil
  end

end
