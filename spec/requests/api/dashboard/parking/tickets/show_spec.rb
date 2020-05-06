require 'rails_helper'

RSpec.describe Api::Dashboard::AgenciesController, type: :request do
  let(:admin) { create(:admin, role: super_admin_role) }
  let!(:agency) { create(:agency) }
  let!(:violation) { create(:parking_violation) }
  let!(:parking_ticket) { create(:parking_ticket, status: :resolved) }

  before do
  end

  describe 'GET #show' do
    context 'success' do
      subject do
        get "/api/dashboard/parking/tickets/#{parking_ticket.id}", headers: { Authorization: get_auth_token(admin) }
      end

      it_behaves_like 'response_200', :show_in_doc

      it 'returns right attributes' do
        subject
        expect(json[:id]).to eq(parking_ticket.id)
        expect(json[:status]).to eq(parking_ticket.status)
        expect(json[:agency][:id]).to eq(parking_ticket.agency.id)
      end

    end
  end
end
