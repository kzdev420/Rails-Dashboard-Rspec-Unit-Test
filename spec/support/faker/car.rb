module Faker
  class Car
    def self.number
      chars = %w(A B C E T M)
      str = ""
      3.times { str += chars.sample }
      "#{str}-#{(rand * 10_000).to_i.to_s}"
    end

    def self.type
      %w(sedan bike miniven).sample
    end
  end
end
