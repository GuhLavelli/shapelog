class Goal < ApplicationRecord
  belongs_to :user

  validates :starting_weight, presence: true, numericality: { greater_than: 0 }
  validates :target_weight,   presence: true, numericality: { greater_than: 0 }
  validates :start_date,      presence: true
  validates :weekly_target,   numericality: { greater_than: 0 }, allow_nil: true
  validate :target_weight_must_differ_from_starting_weight

  def direction
    return if starting_weight.blank? || target_weight.blank?

    target_weight > starting_weight ? :gain : :loss
  end

  def total_change_needed
    return 0 if starting_weight.blank? || target_weight.blank?

    (target_weight - starting_weight).abs
  end

  def progress_percent(current_weight)
    return nil if current_weight.blank? || total_change_needed <= 0

    change_so_far = if direction == :gain
      current_weight - starting_weight
    else
      starting_weight - current_weight
    end

    ((change_so_far / total_change_needed) * 100).clamp(0, 100).round(1)
  end

  def estimated_weeks_remaining(current_weight)
    return nil if weekly_target.blank? || weekly_target <= 0 || current_weight.blank?

    remaining_change = if direction == :gain
      target_weight - current_weight
    else
      current_weight - target_weight
    end

    return 0 if remaining_change <= 0

    (remaining_change / weekly_target).ceil
  end

  private

  def target_weight_must_differ_from_starting_weight
    return if starting_weight.blank? || target_weight.blank?
    return if starting_weight != target_weight

    errors.add(:target_weight, "deve ser diferente do peso inicial")
  end
end
