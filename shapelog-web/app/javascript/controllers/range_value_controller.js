import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "output"]

  connect() {
    this.sync()
  }

  sync() {
    this.outputTarget.textContent = this.inputTarget.value
  }
}
