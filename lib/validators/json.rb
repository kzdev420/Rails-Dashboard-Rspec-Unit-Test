module Validators
  class Json < ActiveModel::Validator
    def initialize(*args)
      super
      @attribute = options[:attribute]
      @keys = options[:keys]
      @encoded = options.fetch(:encoded, false)
      @save = options.fetch(:save, false)

      if @attribute.blank? || @keys.blank?
        raise 'missing required options: :keys, :attribute'
      end
    end

    def validate(record)
      json = if @encoded
        Base64.decode64(record.send(@attribute))
      else
        record.send(@attribute)
      end

      hash = begin
        JSON.parse(json, symbolize_names: true)
      rescue JSON::ParserError => exc
        record.errors.add(@attribute, :invalid, error: exc.message)
        record.send(:throw, :abort)
      end

      missing_keys = @keys.each_with_object([]) do |required_key, memo|
        next if hash.key?(required_key)
        memo << required_key
      end

      if missing_keys.any?
        record.errors.add(@attribute, :missing_keys, keys: missing_keys.join(', '))
        record.send(:throw, :abort)
      end

      record.send("#{@attribute}=", hash) if @save
    end
  end
end
