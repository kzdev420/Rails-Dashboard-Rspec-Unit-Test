module DropdownFields
  module Mobile
    class PaymentParkingLotFilter < ::DropdownFields::Base

      def execute
        user = User.find_by(email: params[:user_email])
        user.payments.includes(:parking_lot).map(&:parking_lot).uniq
      end

      def value_attr
        :id
      end

      def label_attr
        :name
      end

    end
  end
end
