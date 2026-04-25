require "test_helper"

class MedicationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @medication = medications(:one)
  end

  test "index requires login" do
    get medications_path

    assert_redirected_to new_session_path
  end

  test "index renders only medications for the authenticated user" do
    sign_in_as(@user)

    get medications_path

    assert_response :success
    assert_match "Medicamentos", response.body
    assert_match @medication.name, response.body
    assert_no_match medications(:two).name, response.body
  end

  test "show renders owned medication" do
    sign_in_as(@user)

    get medication_path(@medication)

    assert_response :success
    assert_match @medication.name, response.body
    assert_match "Registro detalhado", response.body
  end

  test "show cannot access another users medication" do
    sign_in_as(@user)

    get medication_path(medications(:two))

    assert_response :not_found
  end

  test "new defaults to current day and time" do
    sign_in_as(@user)

    travel_to Time.zone.local(2026, 4, 18, 10, 45, 0) do
      get new_medication_path

      assert_response :success
      assert_match 'value="18/04/2026"', response.body
      assert_match 'value="10:45"', response.body
    end
  end

  test "create with valid params creates medication and option" do
    sign_in_as(@user)

    assert_difference("Medication.count", 1) do
      assert_difference("MedicationOption.count", 1) do
        post medications_path, params: {
          medication: {
            medication_name: "Dipirona",
            taken_at_date: "18/04/2026",
            taken_at_time: "09:15",
            dosage: "500",
            dosage_unit: "mg",
            administration_site: "Bolsa",
            side_effects: "Sem efeitos",
            notes: "Após o café"
          }
        }
      end
    end

    medication = Medication.order(:created_at).last

    assert_redirected_to medication_path(medication)
    assert_equal "Dipirona", medication.name
    assert_equal "dipirona", medication.medication_option.normalized_name
    assert_equal Time.zone.local(2026, 4, 18, 9, 15), medication.taken_at
  end

  test "create reuses existing canonical option when the name matches exactly" do
    sign_in_as(@user)

    assert_difference("Medication.count", 1) do
      assert_no_difference("MedicationOption.count") do
        post medications_path, params: {
          medication: {
            medication_name: "Creatina",
            taken_at_date: "18/04/2026",
            taken_at_time: "09:30",
            dosage: "5",
            dosage_unit: "g"
          }
        }
      end
    end

    assert_redirected_to medication_path(Medication.order(:created_at).last)
    assert_equal medication_options(:creatina), Medication.order(:created_at).last.medication_option
  end

  test "create rejects differently cased duplicate with canonical suggestion" do
    sign_in_as(@user)
    @user.medication_options.create!(name: "Dipirona")

    assert_no_difference("Medication.count") do
      post medications_path, params: {
        medication: {
          medication_name: "dIpIrOnA",
          taken_at_date: "18/04/2026",
          taken_at_time: "09:30",
          dosage: "500",
          dosage_unit: "mg"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_match "Medicamento já existe como Dipirona", response.body
  end

  test "update changes owned medication" do
    sign_in_as(@user)
    option = @user.medication_options.create!(name: "Magnésio")

    patch medication_path(@medication), params: {
      medication: {
        medication_name: option.name,
        taken_at_date: "16/04/2026",
        taken_at_time: "07:10",
        dosage: "2,5",
        dosage_unit: "mg",
        notes: "Antes do treino"
      }
    }

    assert_redirected_to medication_path(@medication)
    assert_equal option, @medication.reload.medication_option
    assert_equal BigDecimal("2.5"), @medication.dosage
    assert_equal Time.zone.local(2026, 4, 16, 7, 10), @medication.taken_at
    assert_equal "Antes do treino", @medication.notes
  end

  test "update cannot access another users medication" do
    sign_in_as(@user)

    patch medication_path(medications(:two)), params: {
      medication: {
        medication_name: "Creatina",
        taken_at_date: "18/04/2026",
        taken_at_time: "09:30",
        dosage: "4",
        dosage_unit: "g"
      }
    }

    assert_response :not_found
  end

  test "destroy removes owned medication" do
    sign_in_as(@user)

    assert_difference("Medication.count", -1) do
      delete medication_path(@medication)
    end

    assert_redirected_to medications_path
  end
end
