module Parking::Rules
  class UpdateMultiple < ApplicationInteraction
    integer :lot_id
    array :rules

    def execute
      ActiveRecord::Base.transaction do
        rules.each do |rule|
          result = ::Parking::Rules::Update.run(rule.merge(lot_id: lot_id))
          if result.errors.any?
            errors.add(:base, :unexpected)
            raise ActiveRecord::Rollback
          end
        end
      end
    end
  end
end
