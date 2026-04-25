class BodyMeasurement < ApplicationRecord
  belongs_to :user

  validates :date, presence: true
  validates :waist, numericality: { greater_than: 0 }, allow_nil: true
  validates :chest, numericality: { greater_than: 0 }, allow_nil: true
  validates :arm,   numericality: { greater_than: 0 }, allow_nil: true
  validates :thigh, numericality: { greater_than: 0 }, allow_nil: true
end
