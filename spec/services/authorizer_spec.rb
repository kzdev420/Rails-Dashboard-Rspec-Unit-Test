require 'rails_helper'

RSpec.describe Authorizer, type: :service do

  context '#generate_token' do
    let!(:user) { create(:user) }

    it 'token should contain user_id' do
      result = described_class.generate_token(user)
      expect(result.include?("#{user.id}:")).to eq(true)
    end

    it 'it should create user token' do
      expect { described_class.generate_token(user) }.to change(User::Token, :count).by(1)
    end

    it 'token should be valid' do
      result = described_class.generate_token(user)
      auth_token = result.split(':').last
      token = user.tokens.last
      expect(token.value).to eq(token.class.encrypt(auth_token))
    end
  end

  context '#authorize_by_token' do
    let!(:admin) { create(:admin) }
    let!(:token) { described_class.generate_token(admin) }

    it 'should be authorized' do
      expect(described_class.authorize_by_token(token, Admin)).to eq(admin)
    end
  end
end
