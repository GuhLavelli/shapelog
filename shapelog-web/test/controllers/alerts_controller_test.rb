require "test_helper"

class AlertsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @email_alert = alerts(:email_alert)
  end

  test "index requires login" do
    get alerts_path
    assert_redirected_to new_session_path
  end

  test "index renders for authenticated user" do
    sign_in_as(@user)
    get alerts_path
    assert_response :success
    assert_match "Alertas", response.body
    assert_match "Segunda-feira", response.body
  end

  test "new renders email form" do
    sign_in_as(@user)
    get new_alert_path(channel: :email)
    assert_response :success
    assert_match "Novo alerta", response.body
    assert_match "Dia da semana do disparo", response.body
  end

  test "new renders whatsapp form" do
    sign_in_as(@user)
    get new_alert_path(channel: :whatsapp)
    assert_response :success
    assert_match "Novo alerta", response.body
  end

  test "create email alert" do
    sign_in_as(@user)

    assert_difference("Alert.count", 1) do
      post alerts_path, params: {
        alert: {
          channel: "email",
          periodicity: "weekly",
          dispatch_time: "08:00",
          dispatch_weekday: "monday",
          report_type: "simple_report",
          recipients: ["test@example.com"]
        }
      }
    end

    assert_redirected_to alerts_path
    alert = Alert.last
    assert alert.email?
    assert_equal ["test@example.com"], alert.recipients
    assert_equal "monday", alert.dispatch_weekday
  end

  test "create whatsapp alert forces reminder type" do
    sign_in_as(@user)

    assert_difference("Alert.count", 1) do
      post alerts_path, params: {
        alert: {
          channel: "whatsapp",
          periodicity: "weekly",
          dispatch_time: "09:00",
          report_type: "insights",
          phone_number: "(11) 99999-9999"
        }
      }
    end

    assert_redirected_to alerts_path
    assert Alert.last.reminder?
  end

  test "create with invalid params renders errors" do
    sign_in_as(@user)

    assert_no_difference("Alert.count") do
      post alerts_path, params: {
        alert: {
          channel: "email",
          periodicity: "weekly",
          dispatch_time: "08:00",
          dispatch_weekday: "",
          report_type: "simple_report",
          recipients: ["test@example.com"]
        }
      }
    end

    assert_response :unprocessable_entity
    assert_match "dia da semana", response.body.downcase
  end

  test "edit renders form" do
    sign_in_as(@user)
    get edit_alert_path(@email_alert)
    assert_response :success
    assert_match "Editar alerta", response.body
    assert_match "Segunda-feira", response.body
  end

  test "update changes alert" do
    sign_in_as(@user)

    patch alert_path(@email_alert), params: {
      alert: { periodicity: "biweekly", dispatch_weekday: "friday" }
    }

    assert_redirected_to alerts_path
    assert_equal "biweekly", @email_alert.reload.periodicity
    assert_equal "friday", @email_alert.dispatch_weekday
  end

  test "destroy removes alert" do
    sign_in_as(@user)

    assert_difference("Alert.count", -1) do
      delete alert_path(@email_alert)
    end

    assert_redirected_to alerts_path
  end
end
