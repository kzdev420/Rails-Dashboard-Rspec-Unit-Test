require 'rails_helper'

RSpec.describe Ai::EventDispatcher, type: :service do
  let!(:parking_lot) { create(:parking_lot) }
  let!(:vehicle) { create(:vehicle) }

  describe 'car entrance' do

    context 'known car' do
      subject do
        payload = car_entrance_payload(vehicle.plate_number)
        described_class.dispatch(payload)
      end

      it 'should process event sucessully' do
        expect(subject).to eq(true)
      end

      it 'updates lot state in redis' do
        expect(Ai::Parking::LotStateWorker).to receive(:perform_async).with(parking_lot.id)
        subject
      end

      it 'should create new parking session' do
        expect { subject }.to change(vehicle.reload.parking_sessions, :count).by(1)
      end

      it 'should create new parking image and vehicle image' do
        subject
        expect(ParkingSession.last.vehicle.images.count).to eq(1)
      end

      it 'should create new notification' do
        expect { subject }.to change(User::Notification, :count).by(1)
      end

      it 'should notify user' do
        expect(ParkingUserMailer).to receive(:car_entrance)
          .and_return( double("ParkingUserMailer", deliver_later: true) ).once
        subject
      end

      it 'should save entered_at time' do
        subject
        created_session = vehicle.reload.parking_sessions.last
        expect(created_session.entered_at.present?).to eq(true)
      end

      it 'should create car entrance notification' do
        subject
        expect(User::Notification.last.template.to_sym).to eq(:car_entrance)
      end
    end

    context 'unknown_car' do
      subject do
        params = car_entrance_payload
        params[:parking_session][:plate_number] = 'NEW_PLATE_NUMBER'
        described_class.dispatch(params)
      end

      it 'should process payload successfully' do
        expect(subject).to eq(true)
      end
    end

    context 'unrecognized_entrance' do
      subject do
        params = car_entrance_payload
        params[:parking_session][:plate_number] = 'NULL'
        described_class.dispatch(params)
      end

      it 'should create new parking session' do
        expect { subject }.to change(ParkingSession, :count).by(1)
      end

      it 'shouldnt change notifications count' do
        expect { subject }.to change(User::Notification, :count).by(0)
      end

      it 'should notify admins' do
        expect(ParkingAdminMailer).to receive(:unrecognized_entrance)
          .and_return( double("ParkingAdminMailer", deliver_later: true) ).once
        subject
      end
    end
  end
end
