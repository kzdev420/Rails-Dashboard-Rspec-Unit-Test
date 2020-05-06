module ActiveRecord
  module Type
    class Encrypted < String
      SALT = 'attribute'.freeze # does not need to be hidden in ENV cuz it will be encrypted using secret_key_base

      def deserialize(value)
        if value.present?
          ActiveSupport::MessageEncryptor.new(encrypted_key).decrypt_and_verify(value)
        end
      end

      def serialize(value)
        if value.present?
          ActiveSupport::MessageEncryptor.new(encrypted_key).encrypt_and_sign(value)
        end
      end

      private

      def encrypted_key
        ActiveSupport::KeyGenerator.new(SALT).generate_key(Rails.application.secret_key_base, 32)
      end
    end
  end
end
