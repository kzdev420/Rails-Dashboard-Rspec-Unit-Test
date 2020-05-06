module Api
  module V1
    class PlaceSerializer < ::ApplicationSerializer
      attributes :id, :name, :category, :distance

    end
  end
end