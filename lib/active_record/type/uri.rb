module ActiveRecord
  module Type
    class Uri < Value
      def deserialize(value)
        if value.present?
          URI.parse(value)
        end
      end

      def serialize(value)
        value.to_s
      end
    end
  end
end
