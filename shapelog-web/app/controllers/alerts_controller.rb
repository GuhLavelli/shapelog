class AlertsController < ApplicationController
  before_action :set_alert, only: [:edit, :update, :destroy]

  def index
    @email_alerts = Current.user.alerts.email
    @whatsapp_alerts = Current.user.alerts.whatsapp
  end

  def new
    @alert = Current.user.alerts.build(channel: params[:channel] || :email)
    prefill_recipients if @alert.email?
  end

  def create
    @alert = Current.user.alerts.build(alert_params)
    @alert.report_type = :reminder if @alert.whatsapp?
    prefill_recipients if @alert.email? && @alert.recipients.reject(&:blank?).empty?

    if @alert.save
      redirect_to alerts_path, notice: "Alerta criado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @alert.assign_attributes(alert_params)
    @alert.report_type = :reminder if @alert.whatsapp?

    if @alert.save
      redirect_to alerts_path, notice: "Alerta atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @alert.destroy
    redirect_to alerts_path, notice: "Alerta removido."
  end

  private

  def set_alert
    @alert = Current.user.alerts.find(params[:id])
  end

  def alert_params
    permitted = params.require(:alert).permit(:channel, :periodicity, :dispatch_time, :dispatch_weekday, :report_type, :active, :phone_number, recipients: [])
    permitted[:recipients] = permitted[:recipients]&.reject(&:blank?) || [] if permitted[:recipients]
    permitted
  end

  def prefill_recipients
    @alert.recipients = [Current.user.email_address] if @alert.recipients.blank? || @alert.recipients.reject(&:blank?).empty?
  end
end
