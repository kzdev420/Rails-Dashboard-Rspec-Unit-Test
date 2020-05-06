require 'rails_helper'

RSpec.describe Api::Dashboard::Parking::RulesController, type: :request do
  let!(:lot) { create(:parking_lot) }
  let!(:rules) { create_list(:parking_rule, 2, lot: lot) }
  let!(:admin) { create(:admin, role: super_admin_role) }
  let!(:recipients1) { create_list(:parking_recipient, 5, rule: rules.first) }
  let!(:recipients2) { create_list(:parking_recipient, 5, rule: rules.last) }

  describe 'GET #index' do
    context 'success: by super_admin' do
      subject do
        get "/api/dashboard/parking_rules", headers: { Authorization: get_auth_token(admin) }, params: @params
      end

      it_behaves_like 'response_200', :show_in_doc

      after do
        expect(json.size).to eq(Parking::Rule.names.keys.count)
      end

      it "With new Parking Lot" do
        subject
        json.each do |rule|
          [
            :id,
            :status,
            :lot_id,
            :agency_id,
            :recipients
          ].each do |a|
            expect(rule.with_indifferent_access[a].blank?).to eq(true)
          end
          [
            :description,
            :name
          ].each do |a|
            expect(rule.with_indifferent_access[a].present?).to eq(true)
          end
        end
      end

      it "With existing Parking Lot" do
        @params = { parking_lot_id: lot.id }
        subject
        json.each do |rule|
          [
            :id,
            :description,
            :name
          ].each do |a|
            expect(rule.with_indifferent_access[a].present?).to eq(true)
          end
          expect(rule[:recipients].present?).to eq(rules.include?([:id]) ? true : false)
        end
      end
    end
  end
end
