require 'rails_helper'

RSpec.describe Agency, type: :model do
  describe 'creating agency' do
    it 'has valid factory' do
      agency = create(:agency)
      expect(agency.valid?).to eq(true)
    end
  end
end
