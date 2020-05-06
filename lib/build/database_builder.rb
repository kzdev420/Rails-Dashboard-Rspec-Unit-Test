Dir[Rails.root.join('spec/support/faker/*.rb')].each do |f|
  require f
end

module Build
  class DatabaseBuilder
    def self.run
      new.execute
    end

    def execute
      ActiveRecord::Base.transaction do
        destroy_data

        create_roles
        create_test_admins
        create_agency
        create_parking_lots
        create_camera
        create_manufacturers
        create_kiosk_and_token
        create_ai_token
        create_reports

        if Rails.env.development?
          User.destroy_all
          User.connection.reset_pk_sequence!(User.table_name)
          ['user@gmail.com', 'test@gmail.com'].each do |email|
            User.create(email: email, password: 'password', first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, confirmed_at: DateTime.now, phone: '+17526274136')
          end
        end

        User.find_each do |user|
          create_vehicles(user)
          create_sessions(user)
          create_notifications(user)
          create_dispute(user)
          create_messages(user)
          create_alert(user)
          create_payment(user)
        end

      end
    end

    private

    def destroy_data
      [
        Agency,
        Dispute,
        CoordinateParkingPlan,
        ParkingSlot,
        ParkingLot,
        ParkingSession,
        Vehicle,
        Manufacturer,
        Camera,
        Admin,
        Message,
        Report,
        Role
      ].each do |klass|
        klass.destroy_all
        klass.connection.reset_pk_sequence!(klass.table_name)
      end
    end

    def create_roles
      puts 'creating roles' if Rails.env.production?
      RolesSeedCommand.execute
    end

    def create_test_admins
      puts 'creating test admins' if Rails.env.production?
      password = 'password'

      Admin.create!(
        email: "admin@example.com",
        password: password,
        username: "administrator",
        phone: Faker::Phone.number,
        status: 'active',
        name: "#{Faker::Name.first_name} #{Faker::Name.last_name}",
        role_id: Role.find_by(name: :super_admin).id
      )

      Role.where.not(name: :super_admin).each do |role|
        name =  "#{Faker::Name.first_name} #{Faker::Name.last_name}"
        phone = Faker::Phone.number
        Admin.create!(
          email: "admin.#{role.name}@telesoftmobile.com",
          password: password,
          phone: phone,
          username: "admin#{role.name.sub('_','')}",
          status: 'active',
          name: name,
          role_id: role.id
        )
      end
    end

    def create_agency
      puts 'creating agencies' if Rails.env.production?
      agency = Agency.create!(
        name: 'Best agency',
        email: 'parking@telesoftmobile.com',
        managers: [Admin.manager.first],
        town_managers: [Admin.town_manager.first],
        officers: [Admin.officer.first]
      )
      Location.create!(
        subject: agency,
        country: Faker::Address.country,
        city: Faker::Address.city,
        building: Faker::Address.building_number,
        street: Faker::Address.street_name,
        state: Faker::Address.state,
        ltd: Faker::Address.latitude.to_f,
        lng: Faker::Address.longitude.to_f,
        zip: Faker::Address.zip(Faker::Address.state_abbr)
      )

    end

    def create_parking_lots
      puts 'creating parking lots' if Rails.env.production?
      30.times.each do |i|
        lot = ParkingLot.create!(
          name: "Parking Lot ##{i}",
          email: 'parking@telesoftmobile.com',
          phone: Faker::Phone.number,
          outline: JSON.parse(File.read(Rails.root.join('spec/fixtures/parking_lot.parking'))),
          town_managers: [Admin.town_manager.first]
        )

        Location.create!(
          subject: lot,
          country: Faker::Address.country,
          city: Faker::Address.city,
          building: Faker::Address.building_number,
          street: Faker::Address.street_name,
          state: Faker::Address.state,
          ltd: Faker::Address.latitude.to_f,
          lng: Faker::Address.longitude.to_f,
          zip: Faker::Address.zip(Faker::Address.state_abbr)
        )
        Faker::Number.between(1, 3).times do
          Place.create!(
            name: Faker::Company.name[1...25],
            category: Place.categories.keys.sample,
            distance: Faker::Number.between(1, 100),
            parking_lot: lot
          )
        end
        Parking::Rule.names.values.each do |rule_name|
          Parking::Rule.create!(
            lot: lot,
            name: rule_name,
            agency: Agency.first,
            description: Faker::Lorem.paragraph
          )
        end

        lot.spaces.each_with_index do |space, index|
          ParkingSlot.create!(name: space['space_id'], parking_lot: lot)
        end

        lot.create_setting!(
          rate: 1.0,
          parked: 30.minutes.to_i,
          overtime: 30.minutes.to_i,
          period: 30.minutes.to_i,
          free: 10.minutes.to_i
        )
      end
    end

    def create_notifications(user)
      puts "creating notifications for #{user.email}" if Rails.env.production?
      user.parking_sessions.each do |session|
        4.times do
          [:car_parked, :car_entrance, :car_left, :car_exit].each do |template|
            user.notifications.create!(template: template, parking_session: session, text: Faker::Lorem.sentence)
          end
        end
      end

      User::Notification.last(3).each(&:destroy)
    end

    def create_messages(user)
      puts "creating messages for #{user.email}" if Rails.env.production?
      4.times do
        [:invoice, :violation, :promotion].each do |template|
          user.messages.create!(subject: Dispute.all.sample, template: template, text: Faker::Lorem.sentence, author: Admin.first, to: user)
        end
      end
      Message.last(3).each { |message| message.update(read: true) }
    end

    def create_dispute(user)
      puts "creating dispute for #{user.email}" if Rails.env.production?
      user.parking_sessions.each do |session|
        4.times do
          [:time, :other, :not_me].each do |reason|
            dispute = user.disputes.create!(reason: reason, parking_session: session, admin: Admin.first)
            user.messages.create!(subject: dispute, template: :dispute, text: Faker::Lorem.sentence, author: Admin.first, to: user)
          end
        end
      end
    end

    def create_vehicles(user)
      puts "creating vehicles for #{user.email}" if Rails.env.production?
      5.times do |i|
        user.vehicles.create!(
          plate_number: Faker::Car.number,
          color: Faker::Vehicle.color,
          vehicle_type: Faker::Vehicle.car_type,
          manufacturer: Manufacturer.order(Arel.sql('RANDOM()')).first,
          model: Faker::Vehicle.model
        )
      end
    end

    def create_manufacturers
      %i(Toyota Hyundai Honda Kia Nissan Mazda).each do |manufacturer|
        Manufacturer.create(name: manufacturer)
      end
    end

    def create_sessions(user)
      puts "creating sessions for #{user.email}" if Rails.env.production?
      # current sessions
      lot = ParkingLot.first
      occupied_slots = lot.parking_slots.limit(25)
      occupied_slots.update_all(status: :occupied)
      options = {
        vehicle: user.vehicles.first,
        parking_lot: lot
      }
      t = Time.now
      occupied_slots.each do |slot|
        created_at = rand(2.years).seconds.ago
        ParkingSession.create!(
          options.merge(
            uuid: SecureRandom.hex(10),
            check_in: t - 5.minutes,
            entered_at: t - 5.minutes,
            check_out: t + 25.minutes,
            status: :confirmed,
            parking_slot: slot,
            fee_applied: lot.rate,
            parked_at: created_at,
            created_at: created_at
          )
        )
      end

      # previous sessions
      25.times do |i|
        created_at = rand(2.weeks).seconds.ago
        session = ParkingSession.create!(
          options.merge(
            uuid: SecureRandom.hex(10),
            check_in: t - (i + 1).days,
            check_out: t - (i + 1).days + 30.minutes,
            status: :finished,
            fee_applied: lot.rate,
            parking_slot: occupied_slots.sample,
            parked_at: created_at,
            created_at: created_at
          )
        )
        create_tickets(session) if i % 3
      end

      5.times.each do |i|
        session = ParkingSession.create!(
          options.merge(
            uuid: SecureRandom.hex(10),
            status: :finished,
            created_at: rand(2.weeks).seconds.ago,
            entered_at: t - 5.minutes,
          )
        )
      end
    end

    def create_alert(user)
      puts "creating alert for #{user.email}" if Rails.env.production?
      session = user.parking_sessions.current.first
      if session
        user.alerts.create!(
          subject: session
        )
      end
    end

    def create_camera
      puts "creating camera" if Rails.env.production?
      ParkingLot.first.cameras.create!(
        name: 'The only one camera we have',
        stream: 'rtsp://76.72.141.53/MediaInput/stream_1',
        login: :admin,
        password: 'ZAQ!2wsx',
        vmarkup: JSON.parse(File.read(Rails.root.join('spec/fixtures/camera.vmarkup')))
      )
    end

    def create_ai_token
      Ai::Token.create(name: 'ai_token', value: 'deaff2f8e11ba89531df53c2729b258edeaff2f8e11ba89531df53c2729b258edeaff2f8e11ba895')
    end

    def create_kiosk_and_token
      puts "creating kiosk token" if Rails.env.production?

      kiosk = Kiosk.create!(
        parking_lot: ParkingLot.first
      )
      Ksk::Token.create!(
        kiosk: kiosk,
        name: 'Test token',
        value: 'f9ec6bc77de0507e7302639d6b46a3d79fbe99de6df791cfbe91bb5b68c04abb8f0130a22bd13da2'
      )
    end

    def create_payment(user)
      puts "creating payment for #{user.email}" if Rails.env.production?

      user.parking_sessions.last(3).each do |parking_session|
        if parking_session.finished?
          Payment.create(
            amount: 50,
            payment_method: :cash,
            status: :success,
            parking_session: parking_session
          )
        end
      end
    end

    def create_tickets(session)
      puts "creating tickets for session #{session.id}" if Rails.env.production?

      parking_violation = Parking::Violation.create!({
        session: session,
        rule: Parking::Rule.first,
        vehicle_rule: Parking::VehicleRule.create(lot: session.parking_lot, vehicle_id: session.vehicle_id)
      })

      Parking::Ticket.create!({
        admin: Admin.officer.first,
        agency: Agency.first,
        status: Faker::Number.between(0, 1),
        violation: parking_violation,
        created_at: rand(2.years).seconds.ago
      })
    end

    def create_reports
      20.times do
        Report.create(
          name: "Report #{Faker::Company.name}",
          type: [Agency.first, ParkingLot.first, Vehicle.first].sample,
          created_at: rand(2.years).seconds.ago
        )
      end
    end

  end
end
