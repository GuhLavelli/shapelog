class MedicationOption < ApplicationRecord
  belongs_to :user
  has_many :medications, dependent: :restrict_with_error

  normalizes :name, with: ->(value) { value.to_s.strip.squish.presence }

  scope :recently_used, -> { order(last_used_at: :desc, usage_count: :desc, name: :asc) }

  validates :name, presence: true
  validates :normalized_name, presence: true, uniqueness: { scope: :user_id }

  before_validation :set_normalized_name

  def self.normalize_name(value)
    return if value.blank?

    I18n.transliterate(value.to_s).strip.squish.downcase
  end

  def self.suggestions_for(user:, query:, limit: 8)
    normalized_query = normalize_name(query)
    scope = where(user:)

    return scope.recently_used.limit(limit) if normalized_query.blank?

    scope.where("normalized_name LIKE ?", "#{ApplicationRecord.sanitize_sql_like(normalized_query)}%")
      .recently_used
      .limit(limit)
  end

  def refresh_usage_metadata!
    update_columns(
      usage_count: medications.count,
      last_used_at: medications.maximum(:taken_at),
      updated_at: Time.current
    )
  end

  private
    def set_normalized_name
      self.normalized_name = self.class.normalize_name(name)
    end
end
