class EnablePostgresExtensions < ActiveRecord::Migration[5.2]
  def change
    enable_extension 'cube'
    enable_extension 'earthdistance'
  end
end
