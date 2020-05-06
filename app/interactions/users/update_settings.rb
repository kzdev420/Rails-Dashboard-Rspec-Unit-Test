module Users
  class UpdateSettings < ::ApplicationInteraction

    object :user, class: User
    string :password, default: nil
    string :first_name, default: nil
    string :last_name, default: nil
    string :phone, default: nil
    string :email, default: nil
    integer :is_dev, default: nil
    date :birthday, default: nil
    array :credit_cards_attributes, default: nil
    array :vehicles_attributes, default: nil
    hash :billing_address, default: nil do
      string :address1
      string :city
      string :country_code
      string :state_code
      string :postal_code
    end
    hash :shipping_address, default: nil do
      string :address1, default: nil
      string :city, default: nil
      string :country_code, default: nil
      string :state_code, default: nil
      string :postal_code, default: nil
      boolean :shipping_address_same_as_billing, default: false
    end
    interface :avatar, default: nil # can be File or String
    boolean :delete_avatar, default: false

    validate do
      if password.present?
        unless user.valid_password?(password)
          errors.add(:password, :invalid)
          throw(:abort)
        end
      end
    end

    def execute
      prms = user_params
      ActiveRecord::Base.transaction do
        delete_credit_cards
        delete_vehicles

        unless credit_card_duplicated?
          user.update(prms.merge(credit_cards_attributes: new_cards))
          user.avatar.purge if delete_avatar
          add_errors(user)
          set_default_credit_card unless errors.any?

          create_or_update_user_vehicles
        end

        raise ActiveRecord::Rollback if errors.any?
      end
      self
    end

    def to_model
      user.reload
    end

    def add_errors(result)
      result.errors.each do |key, msg|
        errors.add(:base, msg) unless [:billing_address, :shipping_address].include?(key) # Avoid send wrong error messages
      end
    end

    def delete_credit_cards
      CreditCard.where(id: ids_to_destroy(:credit_cards)).delete_all
    end

    def delete_vehicles
      Vehicle.where(id: ids_to_destroy(:vehicles)).each do |vehicle|
        add_errors(::Vehicles::Delete.run(vehicle: vehicle))
      end
    end

    def create_or_update_user_vehicles
      inputs[:vehicles_attributes]&.each do |vehicle_attr|
        vehicle = user.active_vehicles.find_by(id: vehicle_attr['id'])
        vehicle_attr['plate_number'] = vehicle_attr['plate_number'].downcase
        if vehicle.nil?
          transactional_compose!(::Vehicles::Create, vehicle_params(vehicle_attr).merge(user: user))
        elsif vehicle_changed?(vehicle, vehicle_attr)
          transactional_compose!(::Vehicles::Update, vehicle_params(vehicle_attr).merge(vehicle: vehicle))
        end
      end
    end

    def ids_to_destroy(key)
      return if inputs[:"#{key}_attributes"].nil?

      ids = inputs[:"#{key}_attributes"].map { |e| e.symbolize_keys[:id].to_i }
      ids_matched = []
      user.send(key).each do |association_element|
        ids_matched.push(association_element[:id]) unless ids.include?(association_element[:id])
      end
      ids_matched
    end

    def vehicle_changed?(vehicle, vehicle_attr)
      vehicle.attributes = vehicle_attr.except("id", "created_at", "updated_at")
      vehicle.changed?
    end

    def vehicle_params(attr)
      attr.symbolize_keys.slice(:id, :plate_number, :color, :vehicle_type, :manufacturer_id, :model)
    end

    def user_params
      data = inputs.slice(:first_name, :last_name, :phone, :email, :billing_address, :shipping_address, :birthday, :is_dev ).select { |k,v| v.present? }
      data[:avatar] = { data: inputs[:avatar] } if inputs[:avatar].present?
      data
    end

    def credit_card_duplicated?
      return false if inputs[:credit_cards_attributes].nil?
      credit_cards = inputs[:credit_cards_attributes]&.select { |credit_card| credit_card['id'].nil? }
      credit_cards.each do |credit_card|
        if user.credit_cards.where(number: credit_card.with_indifferent_access[:number]).present?
          errors.add(:credit_card, :duplicated)
          return true
        end
      end
      false
    end

    def new_cards
      return [] if inputs[:credit_cards_attributes].nil?
      credit_cards = inputs[:credit_cards_attributes]&.select { |credit_card| credit_card['id'].nil? }
      credit_cards.map do |credit_card|
        credit_card.slice('number', 'holder_name', 'expiration_year', 'expiration_month')
      end
    end

    def set_default_credit_card
      return if inputs[:credit_cards_attributes].nil?
      user.reload
      credit_card = inputs[:credit_cards_attributes]&.select { |credit_card| credit_card.with_indifferent_access[:default].to_s == '1' }.first
      if credit_card.present?
        credit_card_to_store = user.credit_cards.find_by(id: credit_card.with_indifferent_access[:id]) || user.credit_cards.find_by(number: credit_card.with_indifferent_access[:number])
        user.update(default_credit_card_id: credit_card_to_store&.id || nil)
      elsif user.credit_cards.count > 0
        user.update(default_credit_card_id: user.credit_cards.first.id)
      else
        user.update(default_credit_card_id: nil)
      end
    end

  end
end