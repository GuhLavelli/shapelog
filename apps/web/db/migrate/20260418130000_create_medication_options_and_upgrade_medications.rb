class CreateMedicationOptionsAndUpgradeMedications < ActiveRecord::Migration[8.1]
  class MigrationMedication < ApplicationRecord
    self.table_name = :medications
  end

  class MigrationMedicationOption < ApplicationRecord
    self.table_name = :medication_options
  end

  def up
    create_table :medication_options do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :normalized_name, null: false
      t.integer :usage_count, null: false, default: 0
      t.datetime :last_used_at

      t.timestamps
    end

    add_index :medication_options, [:user_id, :normalized_name], unique: true

    add_reference :medications, :medication_option, foreign_key: true
    add_column :medications, :taken_at, :datetime
    add_column :medications, :dosage_unit, :string

    MigrationMedication.reset_column_information
    MigrationMedicationOption.reset_column_information

    backfill_medication_options_and_fields

    change_column_null :medications, :medication_option_id, false
    change_column_null :medications, :taken_at, false
    change_column_null :medications, :dosage_unit, false

    add_index :medications, [:user_id, :taken_at]
    remove_index :medications, [:user_id, :taken_on] if index_exists?(:medications, [:user_id, :taken_on])

    remove_column :medications, :name, :string
    remove_column :medications, :taken_on, :date
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private
    def backfill_medication_options_and_fields
      MigrationMedication.find_each do |medication|
        canonical_name = cleaned_name(medication[:name])
        normalized_name = normalize_name(canonical_name)

        option = MigrationMedicationOption.find_or_create_by!(user_id: medication.user_id, normalized_name:) do |record|
          record.name = canonical_name
        end

        taken_at = medication[:taken_on].present? ? medication[:taken_on].to_time.in_time_zone.change(hour: 12) : Time.current

        medication.update_columns(
          medication_option_id: option.id,
          taken_at: taken_at,
          dosage_unit: "mg"
        )
      end

      MigrationMedicationOption.find_each do |option|
        refresh_option_usage(option)
      end
    end

    def refresh_option_usage(option)
      option.update_columns(
        usage_count: MigrationMedication.where(medication_option_id: option.id).count,
        last_used_at: MigrationMedication.where(medication_option_id: option.id).maximum(:taken_at),
        updated_at: Time.current
      )
    end

    def cleaned_name(value)
      value.to_s.strip.squish.presence || "Medicamento"
    end

    def normalize_name(value)
      I18n.transliterate(cleaned_name(value)).downcase
    end
end
