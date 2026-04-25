require "test_helper"

class DailyCheckinsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @checkin = daily_checkins(:one)
  end

  test "index requires login" do
    get daily_checkins_path

    assert_redirected_to new_session_path
  end

  test "index renders for authenticated user" do
    sign_in_as(@user)

    get daily_checkins_path

    assert_response :success
    assert_match "Check-ins", response.body
  end

  test "create with valid params" do
    sign_in_as(@user)

    assert_difference("DailyCheckin.count", 1) do
      post daily_checkins_path, params: {
        daily_checkin: {
          date: Date.new(2026, 4, 17),
          weight: 88.7,
          trained: "1",
          cardio: "0",
          anxiolytic_used: "1",
          hunger_level: 4,
          energy_level: 7,
          mood_stress_level: 5,
          notes: "Dia sólido"
        }
      }
    end

    assert_redirected_to daily_checkins_path
  end

  test "new rendered inside today frame submits at top level" do
    sign_in_as(@user)

    get new_daily_checkin_path(date: Date.current), headers: { "Turbo-Frame" => "today_checkin" }

    assert_response :success
    assert_select "turbo-frame#today_checkin form[data-turbo-frame='_top']"
  end

  test "create with invalid params renders errors" do
    sign_in_as(@user)

    assert_no_difference("DailyCheckin.count") do
      post daily_checkins_path, params: {
        daily_checkin: {
          date: "",
          weight: "",
          hunger_level: 14
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "duplicate date renders edit link" do
    sign_in_as(@user)

    assert_no_difference("DailyCheckin.count") do
      post daily_checkins_path, params: {
        daily_checkin: {
          date: @checkin.date,
          weight: 87.9
        }
      }
    end

    assert_response :unprocessable_entity
    assert_match edit_daily_checkin_path(@checkin), response.body
  end

  test "update changes owned checkin" do
    sign_in_as(@user)

    patch daily_checkin_path(@checkin), params: {
        daily_checkin: {
          weight: 85.4,
          mood_stress_level: 6,
          anxiolytic_used: "1"
        }
      }

    assert_redirected_to daily_checkins_path
    assert_equal 85.4, @checkin.reload.weight.to_f
    assert_equal 6, @checkin.mood_stress_level
    assert @checkin.anxiolytic_used?
  end

  test "update cannot access another users checkin" do
    sign_in_as(@user)

    patch daily_checkin_path(daily_checkins(:two)), params: {
      daily_checkin: { weight: 70.0 }
    }

    assert_response :not_found
  end

  test "destroy removes owned checkin" do
    sign_in_as(@user)

    assert_difference("DailyCheckin.count", -1) do
      delete daily_checkin_path(@checkin)
    end

    assert_redirected_to daily_checkins_path
  end

  test "destroy cannot access another users checkin" do
    sign_in_as(@user)

    assert_no_difference("DailyCheckin.count") do
      delete daily_checkin_path(daily_checkins(:two))
    end

    assert_response :not_found
  end
end
