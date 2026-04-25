class DashboardController < ApplicationController
  def index
    @today_checkin = Current.user.daily_checkins.for_date(Current.user, Date.current)
    @recent_checkin = Current.user.daily_checkins.ordered.first
    @current_weight_average = Current.user.current_weight_average
    @goal = Current.user.goal
    @goal_progress_percent = @goal&.progress_percent(@current_weight_average)
    @weekly_training_count = Current.user.daily_checkins.this_week.where(trained: true).count
    @weekly_cardio_count = Current.user.daily_checkins.this_week.where(cardio: true).count
    @training_streak = Current.user.training_streak
    @weeks_tracked = Current.user.weeks_tracked
  end
end
