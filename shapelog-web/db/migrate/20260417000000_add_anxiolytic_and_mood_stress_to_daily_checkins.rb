class AddAnxiolyticAndMoodStressToDailyCheckins < ActiveRecord::Migration[8.1]
  def change
    add_column :daily_checkins, :anxiolytic_used, :boolean, null: false, default: false
    add_column :daily_checkins, :mood_stress_level, :integer
  end
end
