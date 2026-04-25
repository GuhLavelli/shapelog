class DailyCheckin < ApplicationRecord
  belongs_to :user

  scope :ordered, -> { order(date: :desc) }
  scope :recent, ->(limit = 30) { ordered.limit(limit) }
  scope :this_week, -> { where(date: Date.current.beginning_of_week..Date.current.end_of_week) }

  validates :date,   presence: true
  validates :weight, presence: true, numericality: { greater_than: 0 }
  validates :hunger_level, numericality: { only_integer: true, in: 1..10 }, allow_nil: true
  validates :energy_level, numericality: { only_integer: true, in: 1..10 }, allow_nil: true
  validates :mood_stress_level, numericality: { only_integer: true, in: 1..10 }, allow_nil: true
  validates :date, uniqueness: { scope: :user_id, message: "já existe um check-in para esta data" }

  def self.for_date(user, date)
    find_by(user:, date:)
  end

  def date=(value)
    super(parse_localized_date(value))
  end

  def weight=(value)
    super(parse_localized_decimal(value))
  end

  private
    def parse_localized_date(value)
      return value if value.is_a?(Date) || value.is_a?(Time) || value.is_a?(DateTime)
      return value if value.blank?

      Date.strptime(value, "%d/%m/%Y")
    rescue ArgumentError
      value
    end

    def parse_localized_decimal(value)
      return value if value.blank? || value.is_a?(Numeric)

      normalized = value.to_s.strip.tr(",", ".")
      return nil if normalized.blank?

      BigDecimal(normalized)
    rescue ArgumentError
      value
    end
end
