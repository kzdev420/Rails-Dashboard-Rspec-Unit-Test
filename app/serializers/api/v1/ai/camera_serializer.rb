module Api
  module V1
    module Ai
      class CameraSerializer < ApplicationSerializer
        attributes :id, :stream, :vmarkup, :other_information, :allowed
      end
    end
  end
end
