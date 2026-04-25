class CreateAlerts < ActiveRecord::Migration[8.1]
  def change
    create_table :alerts do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :channel, null: false
      t.integer :periodicity, null: false
      t.time :dispatch_time, null: false
      t.integer :report_type, null: false
      t.boolean :active, null: false, default: true
      t.text :recipients, array: true, default: []
      t.string :phone_number

      t.timestamps
    end

    add_index :alerts, [:user_id, :channel]
  end
end
