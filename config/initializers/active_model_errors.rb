ActiveModel::Errors.class_eval do
  def add(attribute, message = :invalid, options = {})
    message = message.call if message.respond_to?(:call)
    detail  = normalize_detail(message, options)
    message = normalize_message(attribute, message, options)&.capitalize # capitalize all messages

    if exception = options[:strict]
      exception = ActiveModel::StrictValidationFailed if exception == true
      raise exception, full_message(attribute, message)
    end

    details[attribute.to_sym]  << detail
    messages[attribute.to_sym] << message
  end
end
