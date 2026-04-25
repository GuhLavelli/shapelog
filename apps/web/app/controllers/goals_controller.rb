class GoalsController < ApplicationController
  before_action :set_goal

  def show
    @current_weight_average = Current.user.current_weight_average
    @progress_percent = @goal.progress_percent(@current_weight_average)
    @estimated_weeks_remaining = @goal.estimated_weeks_remaining(@current_weight_average)
  end

  def edit
  end

  def update
    if @goal.update(goal_params)
      redirect_to goal_path, notice: "Meta atualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_goal
    @goal = Current.user.goal || Current.user.build_goal
  end

  def goal_params
    permitted = params.require(:goal).permit(:starting_weight, :target_weight, :start_date, :weekly_target)

    permitted[:starting_weight] = normalize_decimal(permitted[:starting_weight])
    permitted[:target_weight] = normalize_decimal(permitted[:target_weight])
    permitted[:weekly_target] = normalize_decimal(permitted[:weekly_target])
    permitted[:start_date] = normalize_date(permitted[:start_date])

    permitted
  end

  def normalize_decimal(value)
    return if value.blank?

    value.to_s.strip.tr(",", ".")
  end

  def normalize_date(value)
    return if value.blank?

    raw_value = value.to_s.strip
    return raw_value if raw_value.match?(/\A\d{4}-\d{2}-\d{2}\z/)

    Date.strptime(raw_value, "%d/%m/%Y")
  rescue ArgumentError
    raw_value
  end
end
