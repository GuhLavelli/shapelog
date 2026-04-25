require "test_helper"

class GoalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @goal = goals(:one)
  end

  test "show requires login" do
    get goal_path

    assert_redirected_to new_session_path
  end

  test "edit requires login" do
    get edit_goal_path

    assert_redirected_to new_session_path
  end

  test "update requires login" do
    patch goal_path, params: { goal: { target_weight: 84 } }

    assert_redirected_to new_session_path
  end

  test "show renders current goal" do
    sign_in_as(@user)

    get goal_path

    assert_response :success
    assert_match "Meta", response.body
    assert_match "Média móvel dos últimos 7 check-ins", response.body
  end

  test "show renders empty progress message without checkins" do
    sign_in_as(@user)
    @user.daily_checkins.destroy_all

    get goal_path

    assert_response :success
    assert_match "Sem dados suficientes para calcular o progresso", response.body
  end

  test "edit renders for authenticated user" do
    sign_in_as(@user)

    get edit_goal_path

    assert_response :success
    assert_match "Editar meta", response.body
  end

  test "edit sanitizes decimal goal fields on input" do
    sign_in_as(@user)

    get edit_goal_path

    assert_response :success
    assert_includes response.body, 'name="goal[starting_weight]"'
    assert_includes response.body, 'name="goal[target_weight]"'
    assert_includes response.body, 'name="goal[weekly_target]"'
    assert_equal 3, response.body.scan('data-controller="decimal-input"').size
    assert_equal 3, response.body.scan('input-&gt;decimal-input#sanitize blur-&gt;decimal-input#sanitize').size
  end

  test "update changes existing goal" do
    sign_in_as(@user)

    patch goal_path, params: {
      goal: {
        starting_weight: 92,
        target_weight: 84,
        start_date: Date.new(2026, 4, 1),
        weekly_target: 0.7
      }
    }

    assert_redirected_to goal_path
    assert_equal 84, @goal.reload.target_weight.to_i
    assert_equal 0.7, @goal.weekly_target.to_f
  end

  test "update creates goal on demand" do
    user = users(:two)
    user.goal.destroy!
    sign_in_as(user)

    assert_difference("Goal.count", 1) do
      patch goal_path, params: {
        goal: {
          starting_weight: 80,
          target_weight: 86,
          start_date: Date.new(2026, 4, 17),
          weekly_target: 0.4
        }
      }
    end

    assert_redirected_to goal_path
    assert_equal 86, user.reload.goal.target_weight.to_i
  end

  test "update renders errors with invalid params" do
    sign_in_as(@user)

    patch goal_path, params: {
      goal: {
        starting_weight: 90,
        target_weight: 90,
        start_date: Date.new(2026, 4, 1)
      }
    }

    assert_response :unprocessable_entity
    assert_match "deve ser diferente do peso inicial", response.body
  end
end
