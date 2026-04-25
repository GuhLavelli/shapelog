class CreateDailyCheckins < ActiveRecord::Migration[8.1]
  def change
    create_table :daily_checkins do |t|
      t.references :user, null: false, foreign_key: true
      t.date    :date,              null: false
      t.decimal :weight,            null: false, precision: 5, scale: 2
      t.boolean :trained,           null: false, default: false
      t.boolean :cardio,            null: false, default: false
      t.integer :steps,             null: true
      t.integer :hunger_level,      null: true
      t.integer :energy_level,      null: true
      t.integer :calories_estimate, null: true
      t.decimal :waist,             null: true, precision: 5, scale: 2
      t.text    :notes,             null: true

      t.timestamps
    end

    add_index :daily_checkins, [:user_id, :date], unique: true
  end
end
