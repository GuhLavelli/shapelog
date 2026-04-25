require "test_helper"

class MedicationOptionTest < ActiveSupport::TestCase
  test "normalizes name for uniqueness per user" do
    option = MedicationOption.new(user: users(:one), name: "  dIpIrÔna  ")

    option.valid?

    assert_equal "dIpIrÔna", option.name
    assert_equal "dipirona", option.normalized_name
  end

  test "prevents duplicate normalized names for the same user" do
    MedicationOption.create!(user: users(:one), name: "Dipirona")
    duplicate = MedicationOption.new(user: users(:one), name: "dipirona")

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:normalized_name]
  end

  test "allows the same normalized name for another user" do
    MedicationOption.create!(user: users(:one), name: "Dipirona")
    other_user_option = MedicationOption.new(user: users(:two), name: "dipirona")

    assert other_user_option.valid?
  end
end
