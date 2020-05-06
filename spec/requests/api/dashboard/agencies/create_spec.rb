require 'rails_helper'

RSpec.describe Api::Dashboard::AgenciesController, type: :request do
  let!(:admin) { create(:admin, role: super_admin_role) }
  let!(:manager) { create(:admin, role: manager_role) }
  let!(:town_manager) { create(:admin, role: town_manager_role) }
  let!(:officers) { create_list(:admin, 2, role: officer_role) }
  let!(:parking_admin) { create(:admin, role: parking_admin_role) }

  let(:valid_params) do
    {
      email: Faker::Internet.email,
      name: Faker::Company.name,
      location: {
        country: Faker::Address.country,
        city: Faker::Address.city,
        state: Faker::Address.state,
        building: Faker::Address.building_number,
        street: Faker::Address.street_name,
        zip: Faker::Address.zip(Faker::Address.state_abbr),
        ltd: Faker::Address.latitude,
        lng: Faker::Address.longitude
      },
      phone: Faker::Phone.number,
      manager_id: manager.id,
      town_manager_id: town_manager.id,
      officer_ids: [officers.map(&:id)],
      avatar: fixture_base64_file_upload('spec/files/test.jpg')
    }
  end

  describe 'POST #create' do
    context 'success' do
      subject do
        post '/api/dashboard/agencies', headers: { Authorization: get_auth_token(admin) }, params: {
          agency: valid_params
        }
      end

      it_behaves_like 'response_201', :show_in_doc

      it 'should create new agency' do
        expect { subject }.to change(Agency, :count).by(1)
      end

      it 'should create new location' do
        expect { subject }.to change(Location, :count).by(1)
      end

      it 'should save manager, town manager and officers' do
        subject
        agency = Agency.last
        expect(agency.manager).to eq(manager)
        expect(agency.town_manager).to eq(town_manager)
        expect(Set.new(agency.officers)).to eq(Set.new(officers))
      end

      it 'should send mails' do
        expect(AdminMailer).to receive(:subject_created)
          .and_return( double("AdminMailer", deliver_later: true) ).once
        expect(AdminMailer).to receive(:assigned_to_agency)
          .and_return( double("AdminMailer", deliver_later: true) ).exactly(4).times
        subject
      end
    end

    context 'success: without officers, phone, avatar' do
      context 'officers empty' do
        subject do
          params = valid_params
          post '/api/dashboard/agencies', headers: { Authorization: get_auth_token(admin) }, params: {
            agency: params.except(:officers, :phone, :avatar)
          }
        end

        it_behaves_like 'response_201'
      end

      context 'officers nil' do
        subject do
          params = valid_params
          params[:officers] = nil
          post '/api/dashboard/agencies', headers: { Authorization: get_auth_token(admin) }, params: {
            agency: params.except(:phone, :avatar)
          }
        end

        it_behaves_like 'response_201'
      end
    end

    context 'fail: empty params' do
      subject do
        post '/api/dashboard/agencies', headers: { Authorization: get_auth_token(admin) }, params: {}
      end

      it_behaves_like 'response_422', :show_in_doc
    end

    context 'fail: invalid params: invalid role' do
      subject do
        params = valid_params
        params[:manager_id] = parking_admin.id
        post '/api/dashboard/agencies', headers: { Authorization: get_auth_token(admin) }, params: {
          agency: params
        }
      end

      it_behaves_like 'response_422', :show_in_doc
    end
  end
end
