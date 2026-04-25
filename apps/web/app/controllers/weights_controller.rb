class WeightsController < ApplicationController
  def index
    weights_scope = Current.user.daily_checkins.where.not(weight: nil)
    @checkins = weights_scope.order(date: :desc)
    @latest_checkin = @checkins.first
    @first_checkin = weights_scope.order(:date).first
    @current_weight_average = Current.user.current_weight_average
    @goal = Current.user.goal
    @weight_change = if @latest_checkin.present? && @first_checkin.present?
      (@latest_checkin.weight - @first_checkin.weight).round(2)
    end
    @days_tracked = if @latest_checkin.present? && @first_checkin.present?
      (@latest_checkin.date - @first_checkin.date).to_i
    end
  end
end
