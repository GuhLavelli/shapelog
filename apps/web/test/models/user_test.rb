require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "returns average of the most recent checkins" do
    user = users(:one)

    DailyCheckin.create!(user:, date: Date.new(2026, 4, 10), weight: 101)
    DailyCheckin.create!(user:, date: Date.new(2026, 4, 11), weight: 100)
    DailyCheckin.create!(user:, date: Date.new(2026, 4, 12), weight: 99)
    DailyCheckin.create!(user:, date: Date.new(2026, 4, 13), weight: 98)
    DailyCheckin.create!(user:, date: Date.new(2026, 4, 14), weight: 97)
    DailyCheckin.create!(user:, date: Date.new(2026, 4, 16), weight: 96)

    assert_equal 98.36, user.current_weight_average.to_f
  end

  test "returns average with fewer than seven checkins" do
    user = users(:two)
    DailyCheckin.create!(user:, date: Date.new(2026, 4, 16), weight: 81)
    DailyCheckin.create!(user:, date: Date.new(2026, 4, 17), weight: 83)

    assert_equal 81.33, user.current_weight_average.to_f
  end

  test "returns nil current weight average without checkins" do
    user = User.create!(email_address: "fresh@example.com", password: "password", password_confirmation: "password")

    assert_nil user.current_weight_average
  end

  test "calculates training streak" do
    user = users(:one)

    travel_to Date.new(2026, 4, 18) do
      DailyCheckin.create!(user:, date: Date.current, weight: 96.8, trained: true)
      DailyCheckin.create!(user:, date: Date.current - 1.day, weight: 97.0, trained: true)
      DailyCheckin.create!(user:, date: Date.current - 2.days, weight: 97.2, trained: true)

      assert_equal 3, user.training_streak
    end
  end

  test "calculates tracked weeks from first checkin" do
    user = users(:one)

    travel_to Date.new(2026, 4, 18) do
      DailyCheckin.create!(user:, date: Date.new(2026, 3, 28), weight: 99.1)

      assert_equal 4, user.weeks_tracked
    end
  end

  test "destroy removes medications before medication options" do
    user = User.create!(email_address: "with-meds@example.com", password: "password", password_confirmation: "password")
    option = user.medication_options.create!(name: "Dipirona")
    user.medications.create!(medication_option: option, taken_at: Time.zone.local(2026, 4, 18, 8, 30), dosage: 500, dosage_unit: "mg")

    assert_difference("Medication.count", -1) do
      assert_difference("MedicationOption.count", -1) do
        user.destroy
      end
    end
  end
end
