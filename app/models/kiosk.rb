# frozen_string_literal: true
# Model to handle access to the controllers under the folder controllers/api/v1/ksk/
# This model only help us to manage those request by comparing the Authorization token request with {Ksk::Token Ksk::Token model}
class Kiosk < ApplicationRecord
  belongs_to :parking_lot
  has_many :tokens, class_name: 'Ksk::Token', dependent: :destroy
end
