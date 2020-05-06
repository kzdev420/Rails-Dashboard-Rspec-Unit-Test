module Api
  module V1
    class UserSerializer < ::ApplicationSerializer
      attributes :email, :first_name, :last_name, :phone, :created_at, :birthday, :avatar, :default_credit_card_id, :is_dev
      attribute :billing_address
      attribute :shipping_address

      attribute :vehicles, key: :vehicles_attributes, serializer: ThinVehicleSerializer

      has_many :credit_cards, key: :credit_cards_attributes, serializer: CreditCardSerializer

      def created_at
        utc(object.created_at)
      end

      def billing_address
        Api::V1::AddressSerializer.new(object.billing_address.present? ? object.billing_address : Address.new)
      end

      def shipping_address
        Api::V1::AddressSerializer.new(object.shipping_address.present? ? object.shipping_address : Address.new)
      end

      def vehicles
        object.active_vehicles.includes([:manufacturer]).map { |v| Api::V1::VehicleSerializer.new(v) }
      end

      def avatar
        if object.avatar.attached?
          url = object.avatar_thumbnail
          url_for(url) unless url.nil?
        end
      end

    end
  end
end
