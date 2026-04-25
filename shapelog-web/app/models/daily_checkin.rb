class DailyCheckin < ApplicationRecord
  belongs_to :user

  validates :date,   presence: true
  validates :weight, presence: true, numericality: { greater_than: 0 }
  validates :hunger_level, numericality: { only_integer: true, in: 1..10 }, allow_nil: true
  validates :energy_level, numericality: { only_integer: true, in: 1..10 }, allow_nil: true
  validates :steps,             numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :calories_estimate, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :waist,             numericality: { greater_than: 0 }, allow_nil: true
  validates :date, uniqueness: { scope: :user_id, message: "já existe um check-in para esta data" }
end
