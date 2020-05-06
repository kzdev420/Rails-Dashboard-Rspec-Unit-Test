require 'rails_helper'

roles_allowed_to_create = {
  super_admin: 4,
  system_admin: 4,
  town_manager: 1,
  parking_admin: 0,
  manager: 1,
  officer: 0
}

RSpec.describe Api::Dashboard::AdminsController, type: :request do
  describe 'GET #show' do
    let!(:super_admin) { create(:admin, role: super_admin_role) }
    let!(:system_admin) { create(:admin, role: system_admin_role) }
    let!(:town_manager) { create(:admin, role: town_manager_role) }
    let!(:manager) { create(:admin, role: manager_role) }
    let!(:parking_admin) { create(:admin, role: parking_admin_role) }
    let!(:officer) { create(:admin, role: officer_role) }

    roles_allowed_to_create.each do |role, value|
      context "success with #{role} role" do
        subject do
          get "/api/dashboard/dropdowns/role_id", headers: { Authorization: get_auth_token(send(role)) }, params: { admin_id: send(role).id }
        end

        it_behaves_like 'response_200', :show_in_doc

        it "should return #{value} roles" do
          subject
          expect(json.size).to eq(value)
        end

      end
    end
    context 'Admin Role list' do

      ['manager', 'officer', 'parking_admin', 'town_manager'].each do |role_name|
        subject do
          get "/api/dashboard/dropdowns/admins_by_role-#{role_name}", headers: { Authorization: get_auth_token(send(roles_allowed_to_create.keys.sample)) }
        end

        it "should return all #{role_name}" do
          subject
          expect(json.size).to eq(Admin.send(role_name).count)
        end

      end
    end

    context "Rule's recipients search" do
      let!(:role) { :system_admin }
      let!(:new_admin) { create(:admin, email: "email.test@search.com") }
      let!(:new_admin2) { create(:admin, email: "email.search@gmail.com") }
      let!(:search_text) { "search" }

      subject do
        get "/api/dashboard/dropdowns/parking_rule-recipient", headers: { Authorization: get_auth_token(send(role)) }, params: { email: search_text }
      end

      it "Search email" do
        subject
        expect(json.size).to eq(2)
      end
    end

    context "Rule's agency list" do
      subject do
        get "/api/dashboard/dropdowns/parking_rule-agencies_list", headers: { Authorization: get_auth_token(send(role)) }, params: { admin_id: send(role).id, parking_lot_id: parking_lot_id }
      end

      context "super_admin" do
        let!(:role) { :super_admin }
        let!(:agencies) { create_list(:agency, 5) }
        let!(:rule) { create(:parking_rule) }
        let!(:parking_lot_id) { rule.lot_id }

        it "Super Admin gets a list of all agencies" do
          subject
          expect(json.size).to eq(Agency.count)
        end
      end

      context "parking_admin with already created parking lot" do
        let!(:role) { :parking_admin }
        let!(:agencies) { create_list(:agency, 5) }
        let!(:rule) { create(:parking_rule) }
        let!(:parking_lot_id) { rule.lot_id }

        it "Super Admin gets a list of all agencies" do
          subject
          expect(json.size).to eq(1)
        end
      end

      context "town_manager with already created parking lot" do
        let!(:role) { :town_manager }
        let!(:agencies) { create_list(:agency, 5) }
        let!(:agency) { create(:agency, town_manager_ids: [send(role).id]) }
        let!(:rule) { create(:parking_rule) }
        let!(:parking_lot_id) { rule.lot_id }

        it "Super Admin gets a list of all agencies" do
          subject
          expect(json.size).to eq(2)
        end
      end
    end
  end
end
