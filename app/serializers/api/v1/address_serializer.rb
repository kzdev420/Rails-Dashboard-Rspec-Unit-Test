module Api
  module V1
    class AddressSerializer < ::ApplicationSerializer
      # Make attributes return empty string instead of 'null'
      [:address1, :city, :state_code, :country_code, :postal_code].each do |attr|
        # Tell serializer its an attribute
        attribute attr

        # Define a method with the same name as the attribute that calls the
        # underlying object and to_s on the result
        define_method attr do
          object.send(attr).to_s
        end
      end
    end
  end
end
