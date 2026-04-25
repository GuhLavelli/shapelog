import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  format() {
    let digits = this.element.value.replace(/\D/g, "").slice(0, 11)

    if (digits.length <= 2) {
      this.element.value = digits
    } else if (digits.length <= 7) {
      this.element.value = `(${digits.slice(0, 2)}) ${digits.slice(2)}`
    } else {
      this.element.value = `(${digits.slice(0, 2)}) ${digits.slice(2, 7)}-${digits.slice(7)}`
    }
  }
}
