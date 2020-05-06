module Places
  class Update < ApplicationInteraction

    object :object, class: Place
    string :category
    string :name
    float :distance

    def execute
      transactional_update!(object, inputs.except(:object))
    end

  end
end
