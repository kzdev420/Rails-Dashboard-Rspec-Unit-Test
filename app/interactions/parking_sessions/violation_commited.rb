module ParkingSessions
  class ViolationCommited < BaseEvent
    include CreateWithObject
    include Logging

    string :violation_type
    array :images, default: []

    validate :set_session

    # Hardcoded plate number while permit module gets finished
    PLATE_NUMBERS = [
      'MJT742', 'GMH2', '9BV5305', '3AF4155', '7BW1924', '42C47CD', '56552CF', '5CA3944',
      'ARTZIE', '3AP1614', 'TROIKA', '82847CA', 'EGR573', '7BA6876', '79267BY', '44056CE',
      '14226CE', '49V820', '1BW4578', '3CL5218', '83325CB'
    ]

    validate do
      if PLATE_NUMBERS.include?(session.vehicle.plate_number.upcase)
        errors.add(:base, :car_with_permit)
        throw(:abort)
      end
    end

    def execute
      Parking::Violation.transaction do
        create_violation
        create_ticket
        save_images
        notify_admin
        notify_manager
        notify_user
        notify_recipients
      end
    end

    private

    def create_violation
      vehicle_rule = create_voi
      rule = parking_lot.rules.find_by(name: violation_type)
      create_with_block { transactional_create!(Parking::Violation, rule: rule, session: session, vehicle_rule: vehicle_rule ) }
    end

    def create_ticket
      transactional_create!(Parking::Ticket, violation: object, agency: object.rule.agency, admin: parking_lot.parking_admin)
    end

    def save_images
      images.each do |file|
        transactional_create!(Image, file: { data: file }, imageable: object)
      end
    end

    def notify_admin
      return if parking_lot.email.blank? && parking_lot.parking_admin&.email.blank?
      email = parking_lot.email || parking_lot.parking_admin.email
      ViolationMailer.commited(email, object.id).deliver_later
    end

    def notify_manager
      agency = object.rule.agency
      return if agency.nil?
      return if agency.email.blank? && agency.manager&.email.blank?
      email = agency.email || agency.manager.email
      ViolationMailer.commited(email, object.id).deliver_later
    end

    def notify_user
      vehicle = session.vehicle
      return if vehicle&.user&.email.blank?
      UserNotifier.violation_commited(vehicle.user, session, vehicle.user.email, object.id)
    end

    def notify_recipients
      object.rule.admins.each do |admin|
        ViolationMailer.commited(admin.email, object.id).deliver_later
      end
    end

    def create_voi
      Parking::VehicleRule.find_or_create_by(lot: parking_lot, vehicle_id: session.vehicle_id)
    end
  end
end
