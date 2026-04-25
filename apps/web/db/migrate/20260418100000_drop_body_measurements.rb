class DropBodyMeasurements < ActiveRecord::Migration[8.1]
  def change
    drop_table :body_measurements, if_exists: true
  end
end
