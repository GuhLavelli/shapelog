class CreateGoals < ActiveRecord::Migration[8.1]
  def change
    create_table :goals do |t|
      t.references :user,            null: false, foreign_key: true, index: { unique: true }
      t.decimal :starting_weight,    null: false, precision: 5, scale: 2
      t.decimal :target_weight,      null: false, precision: 5, scale: 2
      t.date    :start_date,         null: false
      t.decimal :weekly_target,      null: true,  precision: 4, scale: 2

      t.timestamps
    end
  end
end
