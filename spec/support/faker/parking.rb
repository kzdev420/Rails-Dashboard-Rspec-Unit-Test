module Faker
  class Parking
    def self.slot
      "ABC-#{(rand * 1_000_000).to_i.to_s}"
    end
  end
end
