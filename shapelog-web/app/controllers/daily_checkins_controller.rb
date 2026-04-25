class DailyCheckinsController < ApplicationController
  before_action :set_checkin, only: [:edit, :update, :destroy]

  def index
    @checkins = Current.user.daily_checkins.ordered.limit(90)
    @today_checkin = Current.user.daily_checkins.for_date(Current.user, Date.current)
  end

  def new
    @checkin = Current.user.daily_checkins.new(date: requested_date || Date.current)
    render_form_for_request
  end

  def create
    @checkin = Current.user.daily_checkins.new(checkin_params)

    if @checkin.save
      redirect_to daily_checkins_path, notice: "Check-in salvo."
    else
      load_existing_checkin_for_duplicate_date
      render_form_for_request(status: :unprocessable_entity)
    end
  end

  def edit
    render_form_for_request
  end

  def update
    if @checkin.update(checkin_params)
      redirect_to daily_checkins_path, notice: "Check-in atualizado."
    else
      load_existing_checkin_for_duplicate_date(except_id: @checkin.id)
      render_form_for_request(status: :unprocessable_entity)
    end
  end

  def destroy
    @checkin.destroy
    redirect_to daily_checkins_path, notice: "Check-in removido."
  end

  private

  def set_checkin
    @checkin = Current.user.daily_checkins.find(params[:id])
  end

  def checkin_params
    params.require(:daily_checkin).permit(
      :date, :weight, :trained, :cardio, :anxiolytic_used,
      :hunger_level, :energy_level, :mood_stress_level, :notes
    )
  end

  def requested_date
    return if params[:date].blank?

    Date.parse(params[:date])
  rescue ArgumentError
    nil
  end

  def load_existing_checkin_for_duplicate_date(except_id: nil)
    return unless @checkin.errors.of_kind?(:date, :taken)

    scope = Current.user.daily_checkins.where(date: @checkin.date)
    scope = scope.where.not(id: except_id) if except_id.present?
    @existing_checkin = scope.first
  end

  def render_form_for_request(status: :ok)
    template = action_name.in?(%w[new create]) ? :new : :edit
    render template, status: status
  end
end
