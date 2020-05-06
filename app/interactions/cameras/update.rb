module Cameras
  class Update < ApplicationInteraction
    object :object, class: Camera

    with_options default: nil do |attr|
      attr.string :name
      attr.string :login
      attr.string :vmarkup
      attr.string :password
      attr.string :stream
      attr.string :other_information
      attr.integer :parking_lot_id
      attr.integer :allowed
    end

    validates_with Validators::Url,
                attribute: :stream

    validates_with Validators::Json,
                   attribute: :vmarkup,
                   encoded: true,
                   save: true,
                   keys: Camera::VMARKUP_KEYS,
                   if: :vmarkup?

    def execute
      object.update(filled_inputs)
    end
  end
end
