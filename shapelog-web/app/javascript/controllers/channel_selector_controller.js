import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["emailFields", "whatsappFields", "channelInput"]

  connect() {
    this.toggle()
  }

  toggle() {
    const checked = this.channelInputTargets.find(el => el.checked || el.type === "hidden")
    const channel = checked ? checked.value : "email"

    const isEmail = channel === "email"

    this.emailFieldsTarget.classList.toggle("hidden", !isEmail)
    this.whatsappFieldsTarget.classList.toggle("hidden", isEmail)

    this.#setFieldsDisabled(this.emailFieldsTarget, !isEmail)
    this.#setFieldsDisabled(this.whatsappFieldsTarget, isEmail)
  }

  #setFieldsDisabled(container, disabled) {
    container.querySelectorAll("input, select, textarea").forEach(el => {
      el.disabled = disabled
    })
  }
}
