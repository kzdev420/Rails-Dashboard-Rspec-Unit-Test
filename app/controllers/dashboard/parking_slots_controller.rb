module Dashboard
  class ParkingSlotsController < AdministrateController
    def reset_sessions
      slot = ParkingSlot.find(params[:id])
      if slot.parking_sessions.any?
        slot.update(status: :free)
        slot.parking_sessions.update_all(status: :finished)
      end
      redirect_to dashboard_parking_slot_path(slot)
    end

    private

    def scoped_resource
      resource_class.unscoped
    end
  end
end
