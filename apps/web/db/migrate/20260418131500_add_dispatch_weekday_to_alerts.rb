class AddDispatchWeekdayToAlerts < ActiveRecord::Migration[8.1]
  def change
    add_column :alerts, :dispatch_weekday, :integer
  end
end
