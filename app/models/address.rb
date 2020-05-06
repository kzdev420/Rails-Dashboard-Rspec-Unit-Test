##
# Model to handle address associated to the {User User model}
# ## Table's Columns
# - addressable_type => [string] Data handled by {https://github.com/code-and-effect/effective_addresses effective_addresses}
# - addressable_id => [integer] Data handled by {https://github.com/code-and-effect/effective_addresses effective_addresses}
# - category => [string] Data handled by {https://github.com/code-and-effect/effective_addresses effective_addresses}
# - full_name => [string] Data handled by {https://github.com/code-and-effect/effective_addresses effective_addresses}
# - address1 => [string] Save first address
# - address2 => [string] Save second address
# - city => [string] Save second city
# - state_code => [string] Save state or state code (in case country is United States)
# - country_code => [string] Save country or country code
# - postal_code => [string] save postal
# - updated_at => [datetime]
# - created_at => [datetime]
class Address < Effective::Address

  validates :state_code,
            inclusion: { in: Carmen::Country.coded('US').subregions.map { |states| states.name.downcase } },
            if: :us_address?

  # @return [String] state or state_code (in case It's from USA country) in lowercase
  def state_code
    self[:state_code]&.downcase
  end

  # @return [Boolean] if address is from the United States
  def us_address?
    country_code.upcase == 'US'
  end

end