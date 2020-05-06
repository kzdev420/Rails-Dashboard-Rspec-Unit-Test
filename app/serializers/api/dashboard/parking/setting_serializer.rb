module Api
  module Dashboard
    module Parking
      class SettingSerializer < ::ApplicationSerializer
        attributes :rate,
                   :parked,
                   :overtime,
                   :period,
                   :subject_id,
                   :subject_type
      end
    end
  end
end
