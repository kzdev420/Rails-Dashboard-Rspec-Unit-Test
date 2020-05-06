class ApplicationInteraction < ActiveInteraction::Base
  include ActionView::Helpers::TranslationHelper

  set_callback :execute, :after, :save_object_errors, if: :object_invalid?

  def self.human_attribute_name(*args)
    super&.downcase
  end

  def valid?(*)
    if instance_variable_defined?(:@_interaction_valid)
      return @_interaction_valid
    end
    if errors.any?
      return @_interaction_valid = false
    end
    super
  end

  def filled_inputs
    inputs.except(:object).select { |_, v| v }
  end

  def invalid?
    !valid?
  end

  def to_model
    respond_to?(:object) ? object : {}
  end

  private

  def object_invalid?
    respond_to?(:object) && object&.invalid?
  end

  def transactional_update!(record, attributes)
    record.update!(attributes)
  rescue ActiveRecord::RecordInvalid
    errors.merge!(record.errors)
    raise ActiveRecord::Rollback
  end

  def transactional_create!(klass, attributes)
    record = klass.new(attributes)
    record.save!
    record
  rescue ActiveRecord::RecordInvalid
    errors.merge!(record.errors)
    raise ActiveRecord::Rollback
  end

  def transactional_compose!(command, *args)
    raise ActiveRecord::Rollback if compose(command, *args).invalid?
  end

  def ids_removed(relationship_name, params_received)
    ids_received = params_received.map { |e| e.symbolize_keys[:id].to_i }
    return object.send(relationship_name).select(:id).map(&:id) - ids_received
  end

  def save_object_errors
    errors.merge!(object.errors)
  end

  def compose(other, *args)
    outcome = other.run(*args)
    if outcome.invalid?
      class_name = ActiveSupport::Inflector.deconstantize(other.to_s)
      errors_new = ActiveInteraction::Errors.new(outcome.errors.messages.keys.map { |key| "#{class_name.downcase}_#{key}" })
      outcome.errors.messages.each do |k,v|
        errors_new.add("#{class_name.downcase}_#{k}", v.first)
      end
      errors.merge!(errors_new)
    end
    outcome
  end
end
