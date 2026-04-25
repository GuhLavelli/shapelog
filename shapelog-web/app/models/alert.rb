class Alert < ApplicationRecord
  belongs_to :user

  enum :channel, { email: 0, whatsapp: 1 }
  enum :periodicity, { daily: 0, weekly: 1, biweekly: 2, monthly: 3 }
  enum :report_type, { simple_report: 0, detailed_report: 1, insights: 2, reminder: 3 }
  enum :dispatch_weekday, {
    sunday: 0,
    monday: 1,
    tuesday: 2,
    wednesday: 3,
    thursday: 4,
    friday: 5,
    saturday: 6
  }, prefix: true

  PERIODICITY_LABELS = {
    "daily" => "Diário",
    "weekly" => "Semanal",
    "biweekly" => "Quinzenal",
    "monthly" => "Mensal"
  }.freeze

  WEEKDAY_LABELS = {
    "sunday" => "Domingo",
    "monday" => "Segunda-feira",
    "tuesday" => "Terça-feira",
    "wednesday" => "Quarta-feira",
    "thursday" => "Quinta-feira",
    "friday" => "Sexta-feira",
    "saturday" => "Sábado"
  }.freeze

  REPORT_TYPE_LABELS = {
    "simple_report" => "Relatório Simples",
    "detailed_report" => "Relatório Detalhado",
    "insights" => "Insights",
    "reminder" => "Lembrete"
  }.freeze

  EMAIL_REPORT_TYPES = %w[simple_report detailed_report insights].freeze
  MAX_RECIPIENTS = 3

  validates :channel, presence: true
  validates :periodicity, presence: true
  validates :dispatch_time, presence: true
  validates :report_type, presence: true

  validates :phone_number, presence: true, if: :whatsapp?
  validate :phone_number_format, if: -> { whatsapp? && phone_number.present? }

  validate :recipients_for_email
  validate :report_type_matches_channel
  validate :dispatch_weekday_for_email_schedule

  def periodicity_label
    PERIODICITY_LABELS[periodicity]
  end

  def report_type_label
    REPORT_TYPE_LABELS[report_type]
  end

  def dispatch_weekday_label
    WEEKDAY_LABELS[dispatch_weekday]
  end

  def dispatch_time_formatted
    dispatch_time&.strftime("%H:%M")
  end

  private
    def dispatch_weekday_for_email_schedule
      return unless email?
      return unless periodicity.in?(%w[weekly biweekly])
      return if dispatch_weekday.present?

      errors.add(:dispatch_weekday, "deve ser informado para alertas semanais ou quinzenais por e-mail")
    end

    def recipients_for_email
      return unless email?

      if recipients.blank? || recipients.reject(&:blank?).empty?
        errors.add(:recipients, "deve ter ao menos um e-mail")
        return
      end

      clean = recipients.reject(&:blank?)

      if clean.size > MAX_RECIPIENTS
        errors.add(:recipients, "pode ter no máximo #{MAX_RECIPIENTS} e-mails")
      end

      clean.each do |addr|
        unless addr.match?(/\A[^@\s]+@[^@\s]+\z/)
          errors.add(:recipients, "contém e-mail inválido: #{addr}")
        end
      end
    end

    def phone_number_format
      cleaned = phone_number.to_s.gsub(/\D/, "")
      unless cleaned.match?(/\A\d{10,11}\z/)
        errors.add(:phone_number, "deve ser um número brasileiro válido com DDD")
      end
    end

    def report_type_matches_channel
      if email? && !EMAIL_REPORT_TYPES.include?(report_type)
        errors.add(:report_type, "inválido para alertas por e-mail")
      end

      if whatsapp? && report_type != "reminder"
        errors.add(:report_type, "deve ser Lembrete para alertas por WhatsApp")
      end
    end
end
