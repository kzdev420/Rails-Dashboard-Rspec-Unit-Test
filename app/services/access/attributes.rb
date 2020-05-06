module Access
  class Attributes < Struct.new(:permissions)
    [:read, :update].each do |action|
      define_method "#{action}?" do |*attributes|
        attributes.each_with_object(HashWithIndifferentAccess.new) do |attribute, memo|
          memo[attribute] = permissions[attribute] ? permissions[attribute][action] : false
        end
      end
    end
  end
end
