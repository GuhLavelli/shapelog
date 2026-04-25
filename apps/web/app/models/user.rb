class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :daily_checkins, dependent: :destroy
  has_many :medications, dependent: :destroy
  has_many :medication_options, dependent: :destroy
  has_many :alerts, dependent: :destroy
  has_one  :goal, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def last_medication
    medications.recent_first.first
  end

  def current_weight_average(window: 7)
    weights = daily_checkins.recent(window).pluck(:weight)
    return if weights.empty?

    (weights.sum / weights.size).round(2)
  end

  def training_streak
    trained_dates = daily_checkins.where(trained: true).order(date: :desc).pluck(:date)
    return 0 if trained_dates.empty?

    cursor = Date.current
    cursor -= 1.day unless trained_dates.include?(cursor)

    streak = 0
    trained_dates.each do |date|
      break unless date == cursor

      streak += 1
      cursor -= 1.day
    end

    streak
  end

  def weeks_tracked
    first_date = daily_checkins.order(:date).pick(:date)
    return 0 unless first_date

    ((Date.current - first_date).to_i / 7) + 1
  end
end
