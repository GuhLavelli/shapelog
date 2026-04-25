class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :daily_checkins, dependent: :destroy
  has_many :mounjaro_applications, dependent: :destroy
  has_many :body_measurements, dependent: :destroy
  has_one  :goal, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
