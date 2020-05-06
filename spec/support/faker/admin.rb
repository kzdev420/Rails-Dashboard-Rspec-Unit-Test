module Faker
  class Admin
    def self.username
      usrnm = Faker::Internet.username
      "#{usrnm}#{6.times.map { (rand * 10).to_i }.join}".gsub(/[^0-9a-z ]/i, '').first(10)
    end
  end
end
