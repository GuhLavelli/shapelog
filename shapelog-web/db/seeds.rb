# Usuário único do app
user = User.find_or_create_by!(email_address: "guhlavelli@gmail.com") do |u|
  u.password = ENV.fetch("SEED_PASSWORD", "changeme123")
end

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
      steps:            rand(4000..12000),
      hunger_level:     rand(3..8),
      energy_level:     rand(4..9),
      calories_estimate: rand(1400..2200),
      waist:            (94.0 - (30 - days_ago) * 0.1 + rand(-0.3..0.3)).round(1),
      notes:            nil
    )
  end

  puts "#{user.daily_checkins.count} check-ins criados."

  # Aplicações Mounjaro (semanais)
  [28, 21, 14, 7].each do |days_ago|
    date = days_ago.days.ago.to_date
    next if user.mounjaro_applications.exists?(application_date: date)

    user.mounjaro_applications.create!(
      application_date: date,
      dose:             2.5,
      application_site: ["abdômen", "coxa"].sample,
      side_effects:     nil,
      notes:            nil
    )
  end

  puts "#{user.mounjaro_applications.count} aplicações criadas."
end
