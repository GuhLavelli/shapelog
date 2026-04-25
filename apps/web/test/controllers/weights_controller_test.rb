require "test_helper"

class WeightsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "index requires login" do
    get weights_path

    assert_redirected_to new_session_path
  end

  test "index renders weight history for authenticated user" do
    sign_in_as(@user)

    get weights_path

    assert_response :success
    assert_match "Evolução de Peso", response.body
    assert_match "Histórico recente", response.body
  end

  test "index renders empty state without weight records" do
    sign_in_as(@user)
    @user.daily_checkins.destroy_all

    get weights_path

    assert_response :success
    assert_match "Ainda não há histórico de peso", response.body
  end
end
