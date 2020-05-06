require 'rails_helper'

RSpec.describe User::Notification, type: :model do
  let!(:user) { create(:user, :confirmed, :with_vehicles) }

  describe 'creating a notification' do
    it 'it has valid factory' do
      notification = create(:user_notification, user: user)
      expect(notification.valid?).to eq(true)
    end

    it 'should not allow empty parking_session' do
      expect { create(:user_notification, user: user, parking_session: nil) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'should not allow empty user' do
      expect { create(:user_notification, user: nil) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'should not allow invalid template' do
      expect { create(:user_notification, user: user, template: :invalid) }.to raise_error(ArgumentError)
    end

    it 'should be destroy when parking_session is destroy' do
      notification = create(:user_notification, user: user)
      notification_id = notification.id
      ParkingSession.destroy_all
      expect(User::Notification.find_by(id: notification_id).nil?).to be(true)
    end
  end
end
