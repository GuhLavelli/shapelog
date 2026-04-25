class RemoveStepsAndCaloriesEstimateFromDailyCheckins < ActiveRecord::Migration[8.1]
  def change
    remove_column :daily_checkins, :steps, :integer, if_exists: true
    remove_column :daily_checkins, :calories_estimate, :integer, if_exists: true
  end
end
