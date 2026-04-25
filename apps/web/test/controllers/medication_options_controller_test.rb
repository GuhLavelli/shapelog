require "test_helper"

class MedicationOptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "index requires login" do
    get medication_options_path(q: "cre")

    assert_redirected_to new_session_path
  end

  test "index returns canonical suggestions for authenticated user" do
    sign_in_as(@user)
    @user.medication_options.create!(name: "Dipirona")
    users(:two).medication_options.create!(name: "Diclofenaco")

    get medication_options_path(q: "di"), as: :json

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal ["Dipirona"], payload.fetch("options").map { |option| option.fetch("name") }
  end
end
