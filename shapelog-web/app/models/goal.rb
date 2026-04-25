class Goal < ApplicationRecord
  belongs_to :user

  validates :starting_weight, presence: true, numericality: { greater_than: 0 }
  validates :target_weight,   presence: true, numericality: { greater_than: 0 }
  validates :start_date,      presence: true
  validates :weekly_target,   numericality: { greater_than: 0 }, allow_nil: true
end
