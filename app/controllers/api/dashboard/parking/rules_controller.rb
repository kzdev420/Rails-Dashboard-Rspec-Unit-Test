module Api
  module Dashboard
    class Parking::RulesController < ::Api::Dashboard::ApplicationController

      api :GET, '/api/dashboard/parking_rules', 'Parking rules list'
      header :Authorization, 'Auth token', required: true
      param :per_page, Integer,
            'Items per page count, default is 10. Check response headers for total count (key: F)',
            required: false
      param :page, Integer, 'Items page number', required: false
      param :parking_lot_id, Integer, 'Parking lot ID related to the rules', required: false

      def index
        current_rules = params[:parking_lot_id].present? ? ParkingLot.find(params[:parking_lot_id]).rules.order(name: :desc) : ::Parking::Rule.none
        rules = current_rules.to_a
        ::Parking::Rule.names.keys.sort.each do |key|
          if current_rules.find_by(name: key).nil?
            parking_rule = ::Parking::Rule.new(name: key)
            rules.push(parking_rule)
            parking_rule.update(lot_id: params[:parking_lot_id]) if params[:parking_lot_id].present? # This will happen when a new rule is created and a parking lot already exists
          end
        end
        respond_with rules, each_serializer: ::Api::Dashboard::Parking::RuleSerializer
      end

      api :PUT, '/api/dashboard/parking_rules', 'Update parking rule'
      api :PATCH, '/api/dashboard/parking_rules', 'Update parking rule'
      header :Authorization, 'Auth token', required: true
      param :parking_lot_id, Integer, 'Parking lot ID related to the rules', required: true
      param :parking_rules, Array, of: Hash, required: true do
        param :name, Integer
        param :status, [true, false, 1, 0]
        param :description, String
        param :agency_id, Integer
        param :recipient_ids, Array, of: Hash
      end

      def update
        return parking_lot_not_found! if params[:parking_lot_id].blank? # Ensure we are updating only the rules of one parking lot

        rules = params[:parking_rules]&.map do |parking_rule|
          rule = ::Parking::Rule.find(parking_rule['id'])
          authorize! rule
          parking_rule.merge(object: rule)
        end

        result = ::Parking::Rules::UpdateMultiple.run({
         rules: rules,
         lot_id: params[:parking_lot_id]
        })

        respond_with result, each_serializer: ::Api::Dashboard::Parking::RuleSerializer
      end
    end
  end
end
