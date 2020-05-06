ActiveInteraction::Errors.class_eval do
  # if we merge errors from model or another interaction

  def add(attribute, message = :invalid, **options)
    unless @base.respond_to?(attribute)
      @base.class.send(:attr_reader, attribute)
    end
    super(attribute, message, **options)
  end

  # if we merge errors from model or another interaction

  def merge_detail!(other, attribute, detail, error)
    if attribute?(attribute) || attribute == :base
      add(attribute, error, detail) unless added?(attribute, error, detail)
    else
      translated_error = translate(other, attribute, error, detail)
      message = translated_error
      attribute = attribute.to_sym
      add(attribute, message) unless added?(attribute, message)
    end
  end
end
