module ApplicationHelper
  BUTTON_BASE_CLASSES = "inline-flex items-center justify-center rounded-lg border text-sm font-medium focus:outline-none focus:ring-4 transition-colors disabled:cursor-not-allowed disabled:opacity-60".freeze
  BUTTON_SIZE_CLASSES = {
    sm: "px-3 py-2 text-xs",
    md: "px-5 py-2.5",
    lg: "px-5 py-3"
  }.freeze
  BUTTON_VARIANT_CLASSES = {
    primary: "border-emerald-600 bg-emerald-600 text-white hover:bg-emerald-700 hover:border-emerald-700 focus:ring-emerald-300 dark:border-emerald-500 dark:bg-emerald-500 dark:hover:bg-emerald-600 dark:hover:border-emerald-600 dark:focus:ring-emerald-800",
    secondary: "border-slate-200 bg-white text-slate-900 hover:bg-slate-100 focus:ring-slate-200 dark:border-slate-700 dark:bg-slate-800 dark:text-slate-100 dark:hover:bg-slate-700 dark:focus:ring-slate-700",
    ghost: "border-transparent bg-transparent text-slate-600 hover:bg-slate-100 focus:ring-slate-200 dark:text-slate-300 dark:hover:bg-slate-800 dark:focus:ring-slate-700",
    danger: "border-rose-200 bg-rose-50 text-rose-700 hover:bg-rose-100 focus:ring-rose-200 dark:border-rose-900 dark:bg-rose-950/40 dark:text-rose-300 dark:hover:bg-rose-950/60 dark:focus:ring-rose-900"
  }.freeze
  TEXT_INPUT_CLASSES = "block w-full rounded-xl border border-slate-300 bg-slate-50 p-3 text-sm text-slate-900 shadow-xs focus:border-emerald-500 focus:ring-emerald-500 dark:border-slate-700 dark:bg-slate-950 dark:text-slate-100 dark:placeholder-slate-500".freeze
  TEXTAREA_CLASSES = "block w-full rounded-2xl border border-slate-300 bg-slate-50 px-4 py-3 text-sm text-slate-900 shadow-xs focus:border-emerald-500 focus:ring-emerald-500 dark:border-slate-700 dark:bg-slate-950 dark:text-slate-100 dark:placeholder-slate-500".freeze

  def current_user_display_name
    return "ShapeLog" unless Current.user&.email_address.present?

    Current.user.email_address.split("@").first.tr("._-", " ").squish.titleize
  end

  def button_classes(variant: :primary, size: :md, extra: nil)
    [
      BUTTON_BASE_CLASSES,
      BUTTON_SIZE_CLASSES.fetch(size.to_sym, BUTTON_SIZE_CLASSES[:md]),
      BUTTON_VARIANT_CLASSES.fetch(variant.to_sym, BUTTON_VARIANT_CLASSES[:primary]),
      extra
    ].compact.join(" ")
  end

  def text_input_classes(extra: nil)
    [TEXT_INPUT_CLASSES, extra].compact.join(" ")
  end

  def textarea_classes(extra: nil)
    [TEXTAREA_CLASSES, extra].compact.join(" ")
  end

  def status_badge_classes(active:, tone: :success)
    return "rounded-full bg-slate-100 px-3 py-1 text-xs font-medium text-slate-500 dark:bg-slate-800 dark:text-slate-400" unless active

    case tone.to_sym
    when :warning
      "rounded-full bg-amber-100 px-3 py-1 text-xs font-medium text-amber-800 dark:bg-amber-900/30 dark:text-amber-300"
    else
      "rounded-full bg-emerald-100 px-3 py-1 text-xs font-medium text-emerald-800 dark:bg-emerald-900/40 dark:text-emerald-300"
    end
  end

  def percentage_width(value, max: 100)
    return 0 if value.blank?

    ((value.to_f / max.to_f) * 100).clamp(0, 100)
  end

  def signed_weight_change(delta)
    return "—" if delta.blank?

    formatted = number_with_precision(delta, precision: 1, strip_insignificant_zeros: true)
    "#{delta.to_f.positive? ? '+' : ''}#{formatted} kg"
  end

  def goal_progress_percent(user)
    return nil unless user.goal

    user.goal.progress_percent(user.current_weight_average)
  end

  def goal_direction_label(goal)
    return "—" if goal.direction.blank?

    goal.direction == :gain ? "Ganho de massa" : "Perda de peso"
  end
end
