require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "index requires login" do
    get root_path

    assert_redirected_to new_session_path
  end

  test "index renders dashboard summary for authenticated user" do
    sign_in_as(@user)

    get root_path

    assert_response :success
    assert_match "Dashboard", response.body
    assert_match "Peso mais recente", response.body
    assert_match "Último check-in", response.body
  end

  test "index renders empty state without checkins" do
    sign_in_as(@user)
    @user.daily_checkins.destroy_all

    get root_path

    assert_response :success
    assert_match "Ainda não há dados no dashboard", response.body
  end
end
