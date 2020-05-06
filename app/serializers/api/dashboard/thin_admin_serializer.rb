module Api
  module Dashboard
    class ThinAdminSerializer < ::ApplicationSerializer
      attributes :id, :name, :email
    end
  end
end
