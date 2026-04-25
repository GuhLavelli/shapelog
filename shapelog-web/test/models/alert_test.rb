require "test_helper"

class AlertTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "valid email alert" do
    alert = @user.alerts.build(
      channel: :email,
      periodicity: :weekly,
      dispatch_time: "08:00",
      dispatch_weekday: :monday,
      report_type: :simple_report,
      recipients: ["test@example.com"]
    )
    assert alert.valid?
  end

  test "valid whatsapp alert" do
    alert = @user.alerts.build(
      channel: :whatsapp,
      periodicity: :weekly,
      dispatch_time: "09:00",
      report_type: :reminder,
      phone_number: "(11) 99999-9999"
    )
    assert alert.valid?
  end

  test "email alert requires recipients" do
    alert = @user.alerts.build(
      channel: :email,
      periodicity: :weekly,
      dispatch_time: "08:00",
      dispatch_weekday: :monday,
      report_type: :simple_report,
      recipients: []
    )
    assert_not alert.valid?
    assert alert.errors[:recipients].any?
  end

  test "email alert limits recipients to 3" do
    alert = @user.alerts.build(
      channel: :email,
      periodicity: :weekly,
      dispatch_time: "08:00",
      dispatch_weekday: :monday,
      report_type: :simple_report,
      recipients: ["a@b.com", "c@d.com", "e@f.com", "g@h.com"]
    )
    assert_not alert.valid?
    assert alert.errors[:recipients].any?
  end

  test "email alert validates email format" do
    alert = @user.alerts.build(
      channel: :email,
      periodicity: :weekly,
      dispatch_time: "08:00",
      dispatch_weekday: :monday,
      report_type: :simple_report,
      recipients: ["not-an-email"]
    )
    assert_not alert.valid?
    assert alert.errors[:recipients].any?
  end

  test "whatsapp alert requires phone number" do
    alert = @user.alerts.build(
      channel: :whatsapp,
      periodicity: :weekly,
      dispatch_time: "09:00",
      report_type: :reminder
    )
    assert_not alert.valid?
    assert alert.errors[:phone_number].any?
  end

  test "whatsapp alert must have reminder report type" do
    alert = @user.alerts.build(
      channel: :whatsapp,
      periodicity: :weekly,
      dispatch_time: "09:00",
      report_type: :insights,
      phone_number: "(11) 99999-9999"
    )
    assert_not alert.valid?
    assert alert.errors[:report_type].any?
  end

  test "email alert cannot have reminder report type" do
    alert = @user.alerts.build(
      channel: :email,
      periodicity: :weekly,
      dispatch_time: "08:00",
      dispatch_weekday: :monday,
      report_type: :reminder,
      recipients: ["test@example.com"]
    )
    assert_not alert.valid?
    assert alert.errors[:report_type].any?
  end

  test "weekly email alert requires dispatch weekday" do
    alert = @user.alerts.build(
      channel: :email,
      periodicity: :weekly,
      dispatch_time: "08:00",
      report_type: :simple_report,
      recipients: ["test@example.com"]
    )

    assert_not alert.valid?
    assert alert.errors[:dispatch_weekday].any?
  end

  test "periodicity label" do
    alert = alerts(:email_alert)
    assert_equal "Semanal", alert.periodicity_label
  end

  test "dispatch weekday label" do
    alert = alerts(:email_alert)
    assert_equal "Segunda-feira", alert.dispatch_weekday_label
  end

  test "report type label" do
    alert = alerts(:email_alert)
    assert_equal "Relatório Simples", alert.report_type_label
  end

  test "dispatch time formatted" do
    alert = @user.alerts.build(
      channel: :email,
      periodicity: :weekly,
      dispatch_time: "14:30",
      dispatch_weekday: :friday,
      report_type: :simple_report,
      recipients: ["test@example.com"]
    )
    assert_equal "14:30", alert.dispatch_time_formatted
  end
end
