module Parking::Rules
  class Update < ApplicationInteraction
    string :name, default: nil
    string :description, default: nil
    integer :agency_id, default: nil
    integer :lot_id, default: nil
    boolean :status, default: nil
    array :recipient_ids, default: nil do
      integer
    end

    object :object, class: Parking::Rule

    def execute

      if recipient_ids?
        object.admins = Admin.where(id: recipient_ids)
      else
        object.recipients.delete_all
      end

      object.update(inputs.except(:recipient_ids, :object))

    end
  end
end
