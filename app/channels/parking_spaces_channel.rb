class ParkingSpacesChannel < ApplicationCable::Channel
  def subscribed
    @parking_lot = ParkingLot.find(params[:parking_lot_id])
    stream_from "parking_spaces_channel_#{@parking_lot.id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
