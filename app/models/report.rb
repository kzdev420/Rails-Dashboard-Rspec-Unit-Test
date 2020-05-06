class Report < ApplicationRecord
  belongs_to :type, polymorphic: true
  validates :name, presence: true
end