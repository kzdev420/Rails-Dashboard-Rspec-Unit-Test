module AiEventsHelper
  def car_entrance_payload(plate_number = 'plate_number', timestamp = 5.minutes.ago.to_i)
    {
      event_type: 'car_entrance',
      timestamp: timestamp,
      parking_session: {
        uuid: SecureRandom.hex(8),
        plate_number: plate_number,
        color: 'red',
        vehicle_type: 'car',
        vehicle_images: [
          fixture_base64_file_upload('spec/files/test.jpg')
        ],
        parking_images: [
          fixture_base64_file_upload('spec/files/test.jpg')
        ]
      }
    }
  end

  def violation_commited_payload(session)
    {
      event_type: 'violation_commited',
      violation_type: 'overlapping',
      parking_session: {
        uuid: session.uuid,
        images: [
          fixture_base64_file_upload('spec/files/test.jpg'),
          fixture_base64_file_upload('spec/files/test.jpg')
        ]
      }
    }
  end

  def car_left_payload(session, extra_params = {}, timestamp = 5.minutes.ago.to_i)
    {
      event_type: 'car_left',
      timestamp: timestamp,
      parking_session: {
        uuid: session.uuid,
        plate_number: extra_params[:plate_number],
        vehicle_images: extra_params[:vehicle_images],
        color: extra_params[:color]
      }
    }
  end

  def car_exit_payload(session, extra_params = {}, timestamp = 5.minutes.ago.to_i)
    {
      event_type: 'car_exit',
      timestamp: timestamp,
      parking_session: {
        uuid: session.uuid,
        plate_number: extra_params[:plate_number],
        vehicle_images: extra_params[:vehicle_images],
        color: extra_params[:color]
      }
    }
  end

  def car_parked_payload(session, slot, extra_params = {}, timestamp = 5.minutes.ago.to_i)
    {
      event_type: 'car_parked',
      timestamp: timestamp,
      parking_slot_id: slot.name,
      parking_session: {
        uuid: session.uuid,
        plate_number: extra_params[:plate_number],
        vehicle_images: extra_params[:vehicle_images],
        color: extra_params[:color]
      }
    }
  end
end
