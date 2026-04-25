import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["icon"]

  connect() {
    const saved = localStorage.getItem("theme")
    const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches

    if (saved === "dark" || (!saved && prefersDark)) {
      this.#applyDark(true)
    } else {
      this.#applyDark(false)
    }
  }

  toggle() {
    const isDark = document.documentElement.classList.contains("dark")
    this.#applyDark(!isDark)
    localStorage.setItem("theme", !isDark ? "dark" : "light")
  }

  #applyDark(dark) {
    document.documentElement.classList.toggle("dark", dark)
    if (this.hasIconTarget) {
      this.iconTarget.textContent = dark ? "☀️" : "🌙"
    }
  }
}
