# Usuário único do app
seed_password = ENV.fetch("SEED_PASSWORD", "changeme123")

user = User.find_or_initialize_by(email_address: "guhlavelli@gmail.com")

if user.new_record? || !user.authenticate(seed_password)
  user.password = seed_password
end

user.save!

puts "Usuário: #{user.email_address}"

# ── Dados de demo (opt-in via ENV) ──────────────────────────────────────────
if ENV["SEED_DEMO_DATA"]
  puts "Gerando dados de demo..."

  # Goal
  user.goal ||= user.create_goal!(
    starting_weight: 115.0,
    target_weight:   90.0,
    start_date:      30.days.ago.to_date,
    weekly_target:   0.5
  )

  # 30 dias de check-ins com valores plausíveis
  30.downto(0).each do |days_ago|
    date = days_ago.days.ago.to_date
    next if user.daily_checkins.exists?(date: date)

    base_weight = 115.0 - (30 - days_ago) * 0.17
    weight = (base_weight + rand(-0.5..0.5)).round(1)

    user.daily_checkins.create!(
      date:             date,
      weight:           weight,
      trained:          [true, true, false].sample,
      cardio:           [true, false].sample,
      anxiolytic_used:  [true, false, false].sample,
      hunger_level:     rand(3..8),
      energy_level:     rand(4..9),
      mood_stress_level: rand(3..8),
      notes:            nil
    )
  end

  puts "#{user.daily_checkins.count} check-ins criados."

  # Medicamentos de exemplo (semanais)
  [28, 21, 14, 7].each do |days_ago|
    taken_at = days_ago.days.ago.change(hour: 9, min: 0)
    option = user.medication_options.find_or_create_by!(normalized_name: MedicationOption.normalize_name("Medicamento semanal")) do |record|
      record.name = "Medicamento semanal"
    end

    next if user.medications.exists?(taken_at:, medication_option: option)

    user.medications.create!(
      medication_option:   option,
      taken_at:            taken_at,
      dosage:              2.5,
      dosage_unit:         "mg",
      administration_site: ["abdômen", "coxa"].sample,
      side_effects:        nil,
      notes:               nil
    )
  end

  puts "#{user.medications.count} medicamentos criados."
end
