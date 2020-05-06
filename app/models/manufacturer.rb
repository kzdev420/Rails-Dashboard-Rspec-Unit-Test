##
# Model to handle vehicle manufacturers
# ## Table's Columns
# - name => [string] Manufacturer name
# - created_at => [datetime]
# - updated_at => [datetime]
class Manufacturer < ApplicationRecord
  has_many :vehicles, dependent: :nullify
  validates_uniqueness_of :name
  validates :name, presence: true

  before_validation do
    self.name = name&.downcase
  end

end
