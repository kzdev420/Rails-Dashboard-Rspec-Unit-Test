##
# Model to store credit card information.
# A credit card is added through the mobile app, on the interactor app/interactions/users/update_settings.rb
# ## Table's Columns
# - user_id => [bigint] ID reference to the {User user modle}
# - cvv => [string] String to storee cvv or cvc
# - holder_name => [string] Name associated to the credit card
# - number => [string] credit card number
# - expiration_month => [integer] Month of the year when the credit card expires
# - expiration_year => [integer] Credit card year expiration
# - created_at => [datetime]
# - updated_at => [datetime]
class CreditCard < ApplicationRecord
  # Symbol used to encrypt credit card number on the API response
  # See: app/serializers/api/v1/credit_card_serializer.rb to get a reference
  ENCRIPTED_SYMBOL = "*".freeze

  belongs_to :user

  # Attribute to handle card expiration error
  attr_reader :credit_card_date

  validates :number,
            :holder_name,
            :expiration_month,
            :expiration_year,
            presence: true

  validates :number, credit_card_number: true

  validates :expiration_month,
   numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 12 }

  validate do |credit_card|
    errors.add(:credit_card_date, :invalid) if card_expired?
  end

  before_validation do
    self.network = CreditCardValidations::Detector.new(number)&.brand
  end

  # Indicate if the credit card has expired or not
  # TODO: Discuss idea of a reminder to change credit
  def card_expired?
    expiration_year.present? &&  expiration_month.present? &&
      (expiration_year < (Time.zone.today.year % 100) || (expiration_year == (Time.zone.today.year % 100) && expiration_month <= Time.now.month))
  end

  def network
    super || CreditCardValidations::Detector.new(self.number)&.brand
  end

end
