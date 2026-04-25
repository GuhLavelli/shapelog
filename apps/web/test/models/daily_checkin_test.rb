require "test_helper"

class DailyCheckinTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "is invalid without required fields" do
    checkin = DailyCheckin.new(user: @user)

    assert_not checkin.valid?
    assert_not_empty checkin.errors[:date]
    assert_not_empty checkin.errors[:weight]
  end

  test "validates score ranges" do
    checkin = DailyCheckin.new(
      user: @user,
      date: Date.current,
      weight: 100,
      hunger_level: 11,
      energy_level: 0,
      mood_stress_level: 99
    )

    assert_not checkin.valid?
    assert_not_empty checkin.errors[:hunger_level]
    assert_not_empty checkin.errors[:energy_level]
    assert_not_empty checkin.errors[:mood_stress_level]
  end

  test "enforces unique date per user" do
    existing = daily_checkins(:one)
    duplicate = DailyCheckin.new(user: existing.user, date: existing.date, weight: 88.4)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:date], "já existe um check-in para esta data"
  end

  test "recent returns newest checkins first with limit" do
    older = DailyCheckin.create!(user: @user, date: Date.new(2026, 4, 10), weight: 90.0)
    newer = DailyCheckin.create!(user: @user, date: Date.new(2026, 4, 16), weight: 89.0)

    assert_equal [newer, daily_checkins(:one)], @user.daily_checkins.recent(2).to_a.first(2)
    assert_not_includes @user.daily_checkins.recent(2), older
  end

  test "this_week returns only current week records" do
    travel_to Time.zone.local(2026, 4, 17, 12, 0, 0) do
      in_week = DailyCheckin.create!(user: @user, date: Date.current.beginning_of_week, weight: 88.0)
      out_of_week = DailyCheckin.create!(user: @user, date: Date.current.beginning_of_week - 1.day, weight: 87.5)

      assert_includes DailyCheckin.this_week, in_week
      assert_not_includes DailyCheckin.this_week, out_of_week
    end
  end
end
