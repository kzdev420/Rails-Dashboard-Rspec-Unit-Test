module Agencies
  class Base < ::ApplicationInteraction
    attr_reader :town_manager, :manager, :officers

    object :current_user, class: Admin

    def to_model
      agency.reload
    end

    private

    def agency_params
      data = inputs.slice(:email, :name, :status, :phone)
      data[:avatar] = { data: inputs[:avatar] } if inputs[:avatar].present?
      data
    end

    def location_params
      location&.slice(:lng, :ltd, :city, :country, :state, :street, :zip, :building)
    end

    def validate_manager
      unless @manager = Admin.manager.find_by(id: manager_id)
        errors.add(:manager_id, :not_found)
        throw(:abort)
      end
    end

    def validate_town_manager
      unless @town_manager = Admin.town_manager.find_by(id: town_manager_id)
        errors.add(:town_manager_id, :not_found)
        throw(:abort)
      end
    end

    def validate_officers
      @officers = Admin.officer.where(id: officer_ids)
      unless officers.count > 0
        errors.add(:officer_ids, :not_found)
        throw(:abort)
      end
    end
  end
end
