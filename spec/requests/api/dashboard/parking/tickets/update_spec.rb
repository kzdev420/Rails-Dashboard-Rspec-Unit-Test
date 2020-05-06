require 'rails_helper'

RSpec.describe Api::Dashboard::Parking::TicketsController, type: :request do
  let!(:ticket) { create(:parking_ticket) }

  subject do
    put "/api/dashboard/parking/tickets/#{ticket.id}",
        headers: { Authorization: get_auth_token(admin) },
        params: params
  end

  describe 'PUT #update' do
    context 'success' do
      let(:admin) { create(:admin, role: super_admin_role) }
      let(:params) { { parking_ticket: { status: :resolved, admin_id: create(:admin).id, remark: :none } } }

      it_behaves_like 'response_200', :show_in_doc

      it 'creates Ticket::Log' do
        expect { subject }.to change(ticket.logs, :count).by(1)
      end

      it 'contains status update log' do
        subject
        status_log = ticket.logs.first.changeset.map { |k, v| k.to_sym }.include?(:status)
        expect(status_log).to be_present
      end

      it 'contains admin_id update log' do
        subject
        admin_log = ticket.logs.first.changeset.map { |k, v| k.to_sym }.include?(:admin_id)
        expect(admin_log).to be_present
      end

      it 'notifies assigned admin per change' do
        message = double(:message)
        allow(message).to receive(:deliver_later)
        expect(TicketMailer).to receive(:ticket_changed).and_return(message).twice
        subject
      end
    end

    context 'unauthorized' do
      let(:admin) { create(:admin, role: town_manager_role) }
      let(:params) { { parking_ticket: { status: :opened } } }

      it_behaves_like 'response_403'
    end

    context 'failure' do
      let(:params) { { parking_ticket: { status: :resolved } } }
      let(:admin) { create(:admin, role: super_admin_role) }

      it 'Cannot update ticket status without a remark' do
        subject
        expect(json[:errors][:remark].present?).to eq(true)
      end
    end
  end
end
