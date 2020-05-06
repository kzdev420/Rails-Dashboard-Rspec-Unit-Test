# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.human_attribute_name(*args)
    super&.downcase
  end
end
