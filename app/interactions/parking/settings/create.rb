module Parking
  module Settings
    class Create < ApplicationInteraction
      include CreateWithObject

      float :rate, default: 10.0
      integer :parked, default: 30.minutes.to_i
      integer :overtime, default: 30.minutes.to_i
      integer :period, default: 5.minutes.to_i
      integer :subject_id
      string :subject_type

      def execute
        simple_create(Parking::Setting)
      end
    end
  end
end
