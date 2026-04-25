class CreateBodyMeasurements < ActiveRecord::Migration[8.1]
  def change
    create_table :body_measurements do |t|
      t.references :user,  null: false, foreign_key: true
      t.date    :date,     null: false
      t.decimal :waist,    null: true, precision: 5, scale: 2
      t.decimal :chest,    null: true, precision: 5, scale: 2
      t.decimal :arm,      null: true, precision: 5, scale: 2
      t.decimal :thigh,    null: true, precision: 5, scale: 2
      t.text    :notes,    null: true

      t.timestamps
    end

    add_index :body_measurements, [:user_id, :date]
  end
end
