require 'rails_helper'

RSpec.describe Api::Dashboard::AgenciesController, type: :request do
  let!(:admin) { create(:admin, role: super_admin_role) }
  let!(:manager) { create(:admin, role: manager_role) }
  let!(:new_manager) { create(:admin, role: manager_role) }
  let!(:officers) { create_list(:admin, 2, role: officer_role) }
  let!(:new_officers) { create_list(:admin, 2, role: officer_role) }
  let!(:parking_admin) { create(:admin, role: parking_admin_role) }
  let!(:agency) { create(:agency, admins: [manager, officers].flatten) }

  let(:valid_params) do
    {
      email: Faker::Internet.email,
      name: Faker::Company.name,
      location: {
        country: Faker::Address.country,
        city: Faker::Address.city,
        building: Faker::Address.building_number,
        street: Faker::Address.street_name,
        zip: Faker::Address.zip(Faker::Address.state_abbr),
        ltd: Faker::Address.latitude,
        lng: Faker::Address.longitude
      },
      manager_id: new_manager.id,
      officer_ids: [new_officers.map(&:id)],
    }
  end

  describe 'PUT #update' do
    context 'success' do
      subject do
        put "/api/dashboard/agencies/#{agency.id}", headers: { Authorization: get_auth_token(admin) }, params: {
          agency: valid_params
        }
      end

      it_behaves_like 'response_200', :show_in_doc

      it 'should update agency params' do
        subject
        agency.reload
        expect(agency.email).to eq(valid_params[:email])
        expect(agency.location.country).to eq(valid_params[:location][:country])
        expect(agency.manager)
      end

      it 'should save manager and officers' do
        subject
        agency = Agency.last
        expect(agency.manager).to eq(new_manager)
        expect(Set.new(agency.officers)).to eq(Set.new(new_officers))
      end

      context 'with parking tickets' do
        let!(:ticket) { create(:parking_ticket, agency: agency, admin: officers[0]) }

        it 'should remove officers from tickets' do
          subject
          ticket.reload
          expect(ticket.admin_id).to eq(nil)
        end
      end

      it 'should send mails' do
        expect(AdminMailer).to receive(:subject_updated)
          .and_return( double("AdminMailer", deliver_later: true) ).once
        expect(AdminMailer).to receive(:assigned_to_agency)
          .and_return( double("AdminMailer", deliver_later: true) ).exactly(3).times
        expect(AdminMailer).to receive(:unassigned_from_agency)
          .and_return( double("AdminMailer", deliver_later: true) ).exactly(3).times
        subject
      end
    end

    context 'success: empty params'  do
      subject do
        put "/api/dashboard/agencies/#{agency.id}", headers: { Authorization: get_auth_token(admin) }
      end

      it_behaves_like 'response_422'
    end

    context 'fail: invalid params: invalid role' do
      subject do
        params = valid_params
        params[:manager_id] = parking_admin.id
        params[:officer_ids] = [parking_admin.id]
        put "/api/dashboard/agencies/#{agency.id}", headers: { Authorization: get_auth_token(admin) }, params: {
          agency: params
        }
      end

      it_behaves_like 'response_422', :show_in_doc
    end
  end
end
