import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  sanitize() {
    const normalized = this.element.value
      .replace(/[^\d.,]/g, "")
      .replace(/\./g, ",")

    const parts = normalized.split(",")

    if (parts.length <= 1) {
      this.element.value = normalized
      return
    }

    this.element.value = `${parts.shift()},${parts.join("")}`
  }
}
