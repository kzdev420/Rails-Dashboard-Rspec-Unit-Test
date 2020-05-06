module Access
  class Attribute < Struct.new(:permissions)
    [:read, :update].each do |action|
      define_method "#{action}?" do |attribute|
        permissions[attribute] ? permissions[attribute][action] : false
      end
    end
  end
end
