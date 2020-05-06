module DropdownFields
  module Dashboard
    class PaymentMethodsList < ::DropdownFields::Base

      def execute
        Payment.payment_methods.map do |payment_method|
          {
            label: payment_method.first,
            value: payment_method.last
          }
        end
      end

      def value_attr
        :value
      end

      def label_attr
        :label
      end

    end
  end
end
