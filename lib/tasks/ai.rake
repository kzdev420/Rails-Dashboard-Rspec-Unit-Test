namespace :ai do
  task update_lot_state: :environment do
    worker = Ai::Parking::LotStateWorker.new

    ParkingLot.transaction do
      puts 'Transaction started'
      ParkingLot.lock.find_each(batch_size: 100) do |lot|
        puts "#{lot.name}-#{lot.id}: #{worker.perform((lot.id))}"
      end
      puts 'Transaction finished'
    end
  end
end
