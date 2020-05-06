require 'rails_helper'

RSpec.describe Api::Dashboard::AdminsController, type: :request do
  describe 'GET #index' do
    let!(:admin) { create(:admin, role: super_admin_role) }
    let!(:manager) { create(:admin, role: manager_role) }
    let!(:suspended_users) { create_list(:admin, 14, role: manager_role, status: :suspended) }
    let!(:active_users) { create_list(:admin, 15, role: officer_role, status: :active, parking_lots: [create(:parking_lot)]) }
    let(:users) { suspended_users + active_users }

    context 'success' do
      subject do
        get '/api/dashboard/admins/search', headers: { Authorization: get_auth_token(admin) }
      end

      it_behaves_like 'response_200', :show_in_doc

      it 'should have 20 users per request' do
        subject
        expect(json.size).to eq(20)
      end
    end

    context 'success: filter by query' do
      let(:field) { [:name, :email, :username].sample }
      let(:query) { { "#{field}": users.find { |u| u.active? && u.role_id == officer_role.id }.public_send(field).last(2) } }

      context 'subset of name, email, username + status, role' do
        subject do
          get '/api/dashboard/admins/search', headers: { Authorization: get_auth_token(admin) }, params: {
            status: :active,
            role_id: officer_role.id,
            query: query
          }
        end

        it_behaves_like 'response_200', :show_in_doc

        it 'should respond with filtred users' do
          subject
          expect(json.size < 20).to eq(true)
          expect(json.map { |u| u['role']['id'] }.uniq.sample ).to eq(officer_role.id)
          expect(json.map { |u| u['status'] }.uniq.sample ).to eq('active')
          expect(json.map { |u| u['name'].include?(query[field]) || u['email'].include?(query[field]) || u['username'].include?(query[field]) }.include?(false)).to eq(false)
        end
      end

      context 'subject id and type' do
        let(:parking_lot) { active_users.last.parking_lots.first }
        subject do
          get '/api/dashboard/admins/search', headers: { Authorization: get_auth_token(admin) }, params: {
            subject_id: parking_lot.id,
            subject_type: 'ParkingLot'
          }
        end

        it_behaves_like 'response_200', :show_in_doc
      end
    end

    context 'success: filter by role_name' do

      context 'with one role name' do
        subject do
          get '/api/dashboard/admins/search', headers: { Authorization: get_auth_token(admin) }, params: {
            role_names: officer_role.name
          }
        end

        it_behaves_like 'response_200', :show_in_doc

        it 'should respond with filtred users' do
          subject
          expect(json.size == 15).to eq(true)
          expect(json.map { |u| u['role']['id'] }.uniq.sample ).to eq(officer_role.id)
        end

      end

      context 'with 2 role names' do
        subject do
          get '/api/dashboard/admins/search', headers: { Authorization: get_auth_token(admin) }, params: {
            per_page: 40,
            role_names: [officer_role.name, manager_role.name]
          }
        end

        it_behaves_like 'response_200', :show_in_doc

        it 'should respond with filtred users' do
          subject
          expect(json.size == 30).to eq(true)
          expect(json.map { |u| u['role']['id'] }.uniq.sample ).to be_in([officer_role.id, manager_role.id])
        end

      end

    end

    context 'success: manager only see officers and other managers' do
      subject do
        get '/api/dashboard/admins/search', headers: { Authorization: get_auth_token(manager) },  params: {
          per_page: 40
        }
      end

      it 'should respond with all managers and officers' do
        subject
        expect(json.size).to eq(users.count)
      end
    end

    context 'success: officer only see other officers ' do
      subject do
        get '/api/dashboard/admins/search', headers: { Authorization: get_auth_token(active_users.last) }
      end

      it 'should respond with all officers' do
        subject
        expect(json.size).to eq(active_users.count - 1)
      end
    end
  end
end
