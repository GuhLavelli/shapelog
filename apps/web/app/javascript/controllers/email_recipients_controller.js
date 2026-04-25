import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "addButton"]
  static values = { max: { type: Number, default: 3 } }

  connect() {
    this.updateAddButton()
  }

  add(event) {
    event.preventDefault()

    if (this.fieldCount >= this.maxValue) return

    const wrapper = document.createElement("div")
    wrapper.classList.add("flex", "items-center", "gap-2")
    wrapper.dataset.emailRecipientsTarget = "entry"

    wrapper.innerHTML = `
      <input type="email" name="alert[recipients][]"
             placeholder="outro@email.com"
             class="${this.inputClasses}"
             inputmode="email" autocomplete="off">
      <button type="button" data-action="click->email-recipients#remove"
              class="shrink-0 rounded-lg p-2 text-slate-400 transition-colors hover:bg-rose-50 hover:text-rose-600 dark:hover:bg-rose-950/30 dark:hover:text-rose-400"
              title="Remover e-mail">
        <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
        </svg>
      </button>
    `

    this.containerTarget.appendChild(wrapper)
    this.updateAddButton()
    wrapper.querySelector("input").focus()
  }

  remove(event) {
    event.preventDefault()
    const entry = event.target.closest("[data-email-recipients-target='entry']")
    if (entry) {
      entry.remove()
      this.updateAddButton()
    }
  }

  updateAddButton() {
    if (this.hasAddButtonTarget) {
      this.addButtonTarget.classList.toggle("hidden", this.fieldCount >= this.maxValue)
    }
  }

  get fieldCount() {
    return this.containerTarget.querySelectorAll("input[name='alert[recipients][]']").length
  }

  get inputClasses() {
    return "block w-full rounded-xl border border-slate-300 bg-slate-50 p-3 text-sm text-slate-900 shadow-xs focus:border-emerald-500 focus:ring-emerald-500 dark:border-slate-700 dark:bg-slate-950 dark:text-slate-100 dark:placeholder-slate-500"
  }
}
