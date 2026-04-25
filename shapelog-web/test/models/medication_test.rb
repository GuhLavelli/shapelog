require "test_helper"

class MedicationTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @option = medication_options(:creatina)
  end

  test "requires medication name taken_at dosage and dosage_unit" do
    medication = Medication.new

    assert_not medication.valid?
    assert_not_empty medication.errors[:medication_name]
    assert_not_empty medication.errors[:taken_at]
    assert_not_empty medication.errors[:dosage]
    assert_not_empty medication.errors[:dosage_unit]
  end

  test "parses localized date time and dosage" do
    medication = Medication.new(
      user: @user,
      medication_option: @option,
      dosage: "2,5",
      dosage_unit: "mg"
    )
    medication.taken_at_date = "18/04/2026"
    medication.taken_at_time = "09:45"

    assert medication.valid?
    assert_equal BigDecimal("2.5"), medication.dosage
    assert_equal Time.zone.local(2026, 4, 18, 9, 45), medication.taken_at
  end

  test "requires positive dosage" do
    medication = Medication.new(
      user: @user,
      medication_option: @option,
      dosage: 0,
      dosage_unit: "mg",
      taken_at: Time.zone.local(2026, 4, 18, 9, 0)
    )

    assert_not medication.valid?
    assert_not_empty medication.errors[:dosage]
  end

  test "orders medications from newest to oldest" do
    older = Medication.create!(
      user: @user,
      medication_option: @option,
      dosage: 1,
      dosage_unit: "mg",
      taken_at: Time.zone.local(2026, 4, 10, 8, 0)
    )
    newer_option = @user.medication_options.create!(name: "Magnésio")
    newer = Medication.create!(
      user: @user,
      medication_option: newer_option,
      dosage: 3,
      dosage_unit: "mg",
      taken_at: Time.zone.local(2026, 4, 18, 11, 0)
    )

    assert_equal [newer, medications(:one), older], Medication.where(user: @user).recent_first.to_a
  end
end
