class MedicationsController < ApplicationController
  before_action :set_medication, only: [:show, :edit, :update, :destroy]

  def index
    @medications = Current.user.medications.includes(:medication_option).recent_first
  end

  def show
  end

  def new
    @medication = Current.user.medications.new(
      taken_at: Time.zone.now,
      dosage_unit: Medication::DEFAULT_DOSAGE_UNIT
    )
  end

  def create
    @medication = Current.user.medications.new
    assign_form_attributes(@medication)

    if resolve_medication_option(@medication) && save_medication(@medication)
      redirect_to medication_path(@medication), notice: "Medicamento registrado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    assign_form_attributes(@medication)

    if resolve_medication_option(@medication) && save_medication(@medication)
      redirect_to medication_path(@medication), notice: "Medicamento atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @medication.destroy
    redirect_to medications_path, notice: "Medicamento removido."
  end

  private
    def set_medication
      @medication = Current.user.medications.includes(:medication_option).find(params[:id])
    end

    def medication_params
      params.require(:medication).permit(
        :medication_name, :taken_at_date, :taken_at_time, :dosage, :dosage_unit,
        :administration_site, :side_effects, :notes
      )
    end

    def assign_form_attributes(medication)
      attributes = medication_params

      medication.assign_attributes(
        dosage: attributes[:dosage],
        dosage_unit: attributes[:dosage_unit],
        administration_site: attributes[:administration_site],
        side_effects: attributes[:side_effects],
        notes: attributes[:notes]
      )
      medication.medication_name = attributes[:medication_name]
      medication.taken_at_date = attributes[:taken_at_date]
      medication.taken_at_time = attributes[:taken_at_time]
    end

    def resolve_medication_option(medication)
      return true if medication.medication_name.blank?

      normalized_name = MedicationOption.normalize_name(medication.medication_name)
      existing_option = Current.user.medication_options.find_by(normalized_name:)

      if existing_option.present?
        if existing_option.name != medication.medication_name
          medication.canonical_name_suggestion = existing_option.name
          medication.errors.add(:medication_name, "já existe como #{existing_option.name}. Use esse nome para evitar duplicidade.")
          return false
        end

        medication.sync_option!(existing_option)
        return true
      end

      option = Current.user.medication_options.build(name: medication.medication_name)
      unless option.valid?
        option.errors.full_messages.each do |message|
          medication.errors.add(:medication_name, message)
        end
        return false
      end

      medication.sync_option!(option)
      true
    end

    def save_medication(medication)
      return false unless medication.valid?

      Medication.transaction do
        medication.medication_option.save! if medication.medication_option&.new_record?
        medication.save!
      end

      true
    rescue ActiveRecord::RecordInvalid
      false
    end
end
