module Cameras
  class Create < ApplicationInteraction
    include CreateWithObject

    string :stream
    integer :parking_lot_id

    with_options default: nil do |attr|
      attr.string :name
      attr.string :login
      attr.string :vmarkup
      attr.string :password
      attr.string :other_information
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
      simple_create(Camera)
    end
  end
end
