class MounjaroApplication < ApplicationRecord
  belongs_to :user

  validates :application_date, presence: true
  validates :dose, presence: true, numericality: { greater_than: 0 }
end
