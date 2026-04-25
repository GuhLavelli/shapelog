class WeightsController < ApplicationController
  def index
    @checkins = Current.user.daily_checkins.where.not(weight: nil).order(date: :desc)
  end
end
