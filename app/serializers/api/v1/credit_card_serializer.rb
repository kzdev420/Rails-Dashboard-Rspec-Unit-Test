module Api
  module V1
    class CreditCardSerializer < ::ApplicationSerializer
      attributes :id, :number, :holder_name, :expiration_month, :expiration_year, :network

      def number
        "#{::CreditCard::ENCRIPTED_SYMBOL * object.number[1..-4].size}#{object.number[-4..-1]}"
      end

    end
  end
end
