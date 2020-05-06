require 'rails_helper'

RSpec.describe Api::Dashboard::Parking::TicketsController, type: :request do
  let(:admin) { create(:admin, role: super_admin_role) }
  let(:admin1) { create(:admin, role: super_admin_role) }
  let!(:agency) { create(:agency) }
  let!(:agency1) { create(:agency) }
  let!(:violation) { create(:parking_violation) }
  let!(:violation1) { create(:parking_violation) }

  before do
    create_list(:parking_ticket, 2, status: :resolved)
    create_list(:parking_ticket, 2, admin: admin, agency: agency, violation: violation)
    create_list(:parking_ticket, 2, admin: admin1, agency: agency1, violation: violation1)
  end

  describe 'GET #index' do
    context 'role restriction' do
      subject { get "/api/dashboard/parking/tickets", headers: { Authorization: get_auth_token(admin) } }

      context 'success: by super_admin' do
        it_behaves_like 'response_200', :show_in_doc
      end

      context 'success: by system_admin' do
        let(:admin) { create(:admin, role: system_admin_role) }
        it_behaves_like 'response_200'
      end

      context 'success: by super_admin' do
        let(:admin) { create(:admin, role: town_manager_role) }
        it_behaves_like 'response_200'
      end

      context 'success: by super_admin' do
        let(:admin) { create(:admin, role: parking_admin_role) }
        it_behaves_like 'response_200'
      end

      context 'success: by super_admin' do
        let(:admin) { create(:admin, role: manager_role) }
        it_behaves_like 'response_200'
      end

      context 'success: by super_admin' do
        let(:admin) { create(:admin, role: officer_role) }
        it_behaves_like 'response_200'
      end
    end

    context 'query' do
      subject { get "/api/dashboard/parking/tickets", headers: { Authorization: get_auth_token(admin) }, params: params }

      context 'type' do
        let(:params) { { type: violation.rule.name } }
        it_behaves_like 'response_200', :show_in_doc
      end

      context 'lot' do
        let(:params) { { query: violation.rule.lot.name[0..-2] } }
        it_behaves_like 'response_200', :show_in_doc
      end

      context 'range' do
        let(:params) do
          {
            range: {
              from: Date.today.strftime("%Y-%-m-%-d"),
              to: Date.today.strftime("%Y-%-m-%-d")
            }
          }
        end

        it_behaves_like 'response_200', :show_in_doc
      end

      context 'agency_id' do
        let(:params) { { agency_id: agency.id } }
        it_behaves_like 'response_200', :show_in_doc
      end

      context 'admin_id' do
        let(:params) { { admin_id: admin.id } }
        it_behaves_like 'response_200', :show_in_doc
      end

      context 'parking_lot_id' do
        let(:params) { { parking_lot_id: violation.rule.lot.id } }
        it_behaves_like 'response_200', :show_in_doc
      end

      context 'status' do
        let(:params) { { status: :resolved } }
        it_behaves_like 'response_200', :show_in_doc
      end

      context 'complex' do
        let(:params) do
          {
            type: violation.rule.name,
            query: violation.rule.lot.name[0..-2],
            range: {
              from: Date.today.strftime("%Y-%-m-%-d"),
              to: Date.today.strftime("%Y-%-m-%-d")
            },
            agency_id: agency.id,
            admin_id: admin.id,
            parking_lot_id: violation.rule.lot.id,
            status: :opened
          }
        end

        it_behaves_like 'response_200', :show_in_doc
      end
    end

    context 'pagination' do
      subject { get "/api/dashboard/parking/tickets", headers: { Authorization: get_auth_token(admin) }, params: { per_page: 1 } }
      it 'contains only one ticket', :show_in_doc do
        subject
        expect(json.size).to eq(1)
      end
    end
  end
end
