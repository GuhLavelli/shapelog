class RemoveWaistFromCheckinsAndMeasurements < ActiveRecord::Migration[8.1]
  def change
    remove_column :daily_checkins, :waist, :decimal, precision: 5, scale: 2
  end
end
