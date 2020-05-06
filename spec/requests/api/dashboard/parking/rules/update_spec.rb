require 'rails_helper'

RSpec.describe Api::Dashboard::Parking::RulesController, type: :request do
  let!(:admin) { create(:admin, role: super_admin_role) }
  let!(:lot) { create(:parking_lot) }
  let!(:parking_rule) { create(:parking_rule, lot: lot) }

  describe 'PUT #update' do
    describe "success" do
      subject do
        put "/api/dashboard/parking_rules", headers: { Authorization: get_auth_token(admin) }, params: {
          parking_lot_id: parking_rule.lot_id,
          parking_rules: [
            {
              id: parking_rule.id,
              status: 1,
              recipient_ids: [admin.id]
            }
          ]
        }
      end

      it_behaves_like 'response_200', :show_in_doc

      it 'changes status' do
        subject
        expect(parking_rule.reload.status).to eq(true)
      end

      it 'sets recipients' do
        subject
        expect(parking_rule.reload.admins).to be_exists
      end
    end

    describe "failure" do
      context "Invalid params" do
          subject do
            put "/api/dashboard/parking_rules", headers: { Authorization: get_auth_token(admin) }, params: @params
          end

          it_behaves_like 'response_404', :show_in_doc

          it 'response_404 missing rule ID' do
            @params = {
              parking_lot_id: parking_rule.lot_id,
              parking_rules: [
                {
                  status: 0,
                  recipient_ids: [admin.id]
                }
              ]
            }
            subject
            expect(response.code).to eq("404")
          end

          it 'response_404 missing parking_lot ID' do
            @params = {
              parking_rules: [
                {
                  id: parking_rule.id,
                  status: 0,
                  recipient_ids: [admin.id]
                }
              ]
            }
            subject
            expect(response.code).to eq("404")
          end
      end

      context 'user does not belong to parking lot' do
        let!(:parking_admin) { create(:admin, role: parking_admin_role) }
        let!(:town_manager) { create(:admin, role: town_manager_role) }
        ['parking_admin', 'town_manager'].each do |role_name|
          subject do
            put "/api/dashboard/parking_rules", headers: { Authorization: get_auth_token(send(role_name)) }, params: {
              parking_lot_id: parking_rule.lot_id,
              parking_rules: [
                {
                  id: parking_rule.id,
                  status: 1,
                  recipient_ids: [admin.id]
                }
              ]
            }
          end

          it_behaves_like 'response_403'

        end
      end
    end
  end
end
