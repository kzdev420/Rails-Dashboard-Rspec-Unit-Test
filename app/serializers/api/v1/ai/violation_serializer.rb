module Api
  module V1
    module Ai
      class ViolationSerializer < ApplicationSerializer
        attributes :id, :description, :fixed_at
        belongs_to :rule, serializer: Api::Dashboard::Parking::RuleSerializer
      end
    end
  end
end
