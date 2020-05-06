require 'rails_helper'

RSpec.describe Api::V1::MessagesController, type: :request do
  let!(:user) { create(:user, :confirmed, :with_vehicles) }
  let(:type) { Message.templates[:invoice] }
  let!(:messages) { create_list(:message, 30, to: user, template: type) }
  let!(:read_messages) { create_list(:message, 30, to: user, read: true) }
  let!(:params) { { per_page: 10, page: 1 } }

  describe 'GET #index' do
    before do
      create_list(:message, 10, to: user, template: :dispute)
    end

    context 'success' do
      subject do
        get '/api/v1/messages', headers: { Authorization: get_auth_token(user) }, params: params
      end

      it_behaves_like 'response_200', :show_in_doc

      it 'with types', :show_in_doc do
        params[:types] = ['invoice']
        subject
        json.each do |message|
          expect(params[:types]).to include(message['type'])
        end
      end
    end
  end

  describe 'PUT #read' do
    context 'success' do
      subject do
        put '/api/v1/messages/read', headers: { Authorization: get_auth_token(user) }, params: {
          messages_ids: messages.last(2).map(&:id)
        }
      end

      it_behaves_like 'response_200', :show_in_doc
    end
  end
  describe 'GET #types' do
    context 'success' do
      subject do
        get '/api/v1/messages/types', headers: { Authorization: get_auth_token(user) }
      end

      it_behaves_like 'response_200', :show_in_doc
    end
  end

  describe 'GET #unread' do
    context 'success' do
      subject do
        get '/api/v1/messages/unread', headers: { Authorization: get_auth_token(user) }
      end

      it 'messages has valid status' do
        subject
        expect(json.first['read']).to eq(false)
      end

      it_behaves_like 'response_200', :show_in_doc
    end
  end

end
