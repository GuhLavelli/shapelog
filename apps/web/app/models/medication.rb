class Medication < ApplicationRecord
  include ActiveSupport::NumberHelper

  DOSAGE_UNITS = %w[mcg mg g ml ui gotas comprimido capsula].freeze
  DEFAULT_DOSAGE_UNIT = "mg".freeze

  belongs_to :user
  belongs_to :medication_option

  attr_accessor :medication_name, :canonical_name_suggestion

  scope :recent_first, -> { order(taken_at: :desc, created_at: :desc) }

  validates :medication_name, presence: true
  validates :taken_at, presence: true
  validates :dosage, presence: true, numericality: { greater_than: 0 }
  validates :dosage_unit, presence: true, inclusion: { in: DOSAGE_UNITS }

  normalizes :dosage_unit, with: ->(value) { value.to_s.strip.downcase.presence }
  normalizes :administration_site, with: ->(value) { value.to_s.strip.squish.presence }

  before_validation :compose_taken_at_from_fields
  before_validation :normalize_multiline_fields
  before_destroy :store_previous_medication_option_id
  after_commit :refresh_related_option_metadata, on: [:create, :update, :destroy]

  validate :medication_option_presence
  validate :taken_at_must_be_parseable

  def medication_name
    @medication_name.presence || medication_option&.name
  end

  def medication_name=(value)
    @medication_name = value.to_s.strip.squish.presence
  end

  def taken_at_date
    @taken_at_date.presence || taken_at&.to_date&.then { I18n.l(_1, format: "%d/%m/%Y") }
  end

  def taken_at_date=(value)
    @taken_at_date = value
  end

  def taken_at_time
    @taken_at_time.presence || taken_at&.strftime("%H:%M")
  end

  def taken_at_time=(value)
    @taken_at_time = value
  end

  def name
    medication_option&.name
  end

  def dosage=(value)
    super(parse_localized_decimal(value))
  end

  def formatted_dosage
    "#{number_to_rounded(dosage, precision: 2, strip_insignificant_zeros: true)} #{dosage_unit_label}"
  end

  def sync_option!(option)
    self.medication_option = option
    self.medication_name = option.name
  end

  private
    def dosage_unit_label
      dosage_unit == "ui" ? "UI" : dosage_unit
    end

    def medication_option_presence
      return if medication_option.present?
      return if medication_name.blank?

      errors.add(:medication_name, "selecione um medicamento existente ou confirme um novo nome")
    end

    def compose_taken_at_from_fields
      return unless defined?(@taken_at_date) || defined?(@taken_at_time)

      if @taken_at_date.blank? || @taken_at_time.blank?
        self.taken_at = nil
        return
      end

      date = Date.strptime(@taken_at_date, "%d/%m/%Y")
      hour, minute = @taken_at_time.to_s.split(":").map(&:to_i)
      self.taken_at = Time.zone.local(date.year, date.month, date.day, hour, minute)
      @taken_at_invalid = false
    rescue ArgumentError, TypeError
      @taken_at_invalid = true
      self.taken_at = nil
    end

    def taken_at_must_be_parseable
      errors.add(:taken_at, "não é válido") if @taken_at_invalid
    end

    def normalize_multiline_fields
      self.side_effects = side_effects.to_s.strip.presence
      self.notes = notes.to_s.strip.presence
    end

    def parse_localized_decimal(value)
      return value if value.blank? || value.is_a?(Numeric)

      BigDecimal(value.to_s.strip.tr(",", "."))
    rescue ArgumentError
      value
    end

    def store_previous_medication_option_id
      @previous_medication_option_id = medication_option_id
    end

    def refresh_related_option_metadata
      option_ids = [medication_option_id, @previous_medication_option_id, medication_option_id_before_last_save].compact.uniq
      MedicationOption.where(id: option_ids).find_each(&:refresh_usage_metadata!)
    end
end
