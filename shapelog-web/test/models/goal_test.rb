require "test_helper"

class GoalTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "is invalid without required fields" do
    goal = Goal.new(user: @user)

    assert_not goal.valid?
    assert_not_empty goal.errors[:starting_weight]
    assert_not_empty goal.errors[:target_weight]
    assert_not_empty goal.errors[:start_date]
  end

  test "requires target weight to differ from starting weight" do
    goal = Goal.new(
      user: @user,
      starting_weight: 90,
      target_weight: 90,
      start_date: Date.current
    )

    assert_not goal.valid?
    assert_includes goal.errors[:target_weight], "deve ser diferente do peso inicial"
  end

  test "detects loss direction and total change" do
    goal = Goal.new(user: @user, starting_weight: 98, target_weight: 85, start_date: Date.current)

    assert_equal :loss, goal.direction
    assert_equal 13, goal.total_change_needed.to_i
  end

  test "detects gain direction and total change" do
    goal = Goal.new(user: @user, starting_weight: 78, target_weight: 84, start_date: Date.current)

    assert_equal :gain, goal.direction
    assert_equal 6, goal.total_change_needed.to_i
  end

  test "calculates progress percent for loss goals" do
    goal = Goal.new(user: @user, starting_weight: 100, target_weight: 90, start_date: Date.current)

    assert_equal 40.0, goal.progress_percent(96)
    assert_equal 0, goal.progress_percent(102)
    assert_equal 100, goal.progress_percent(89)
  end

  test "calculates progress percent for gain goals" do
    goal = Goal.new(user: @user, starting_weight: 70, target_weight: 78, start_date: Date.current)

    assert_equal 50.0, goal.progress_percent(74)
    assert_equal 0, goal.progress_percent(68)
    assert_equal 100, goal.progress_percent(80)
  end

  test "returns nil progress without current weight" do
    goal = Goal.new(user: @user, starting_weight: 100, target_weight: 90, start_date: Date.current)

    assert_nil goal.progress_percent(nil)
  end

  test "estimates weeks remaining for loss and gain goals" do
    loss_goal = Goal.new(user: @user, starting_weight: 100, target_weight: 90, start_date: Date.current, weekly_target: 0.8)
    gain_goal = Goal.new(user: @user, starting_weight: 70, target_weight: 78, start_date: Date.current, weekly_target: 0.5)

    assert_equal 8, loss_goal.estimated_weeks_remaining(96)
    assert_equal 8, gain_goal.estimated_weeks_remaining(74)
    assert_equal 0, loss_goal.estimated_weeks_remaining(89)
    assert_equal 0, gain_goal.estimated_weeks_remaining(79)
  end

  test "returns nil estimated weeks without weekly target" do
    goal = Goal.new(user: @user, starting_weight: 100, target_weight: 90, start_date: Date.current)

    assert_nil goal.estimated_weeks_remaining(95)
  end
end
