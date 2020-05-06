require 'rails_helper'

RSpec.describe Message, type: :model do
  describe 'creating message' do
    it 'has valid factory' do
      message = create(:message)
      expect(message).to be_valid
      expect(message.subject).to be_present
      expect(message.author).to be_present
      expect(message.text).to be_present
      expect(message.to).to be_present
    end
  end
end
