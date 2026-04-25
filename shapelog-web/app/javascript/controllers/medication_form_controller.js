import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["nameInput", "results", "canonicalSuggestion", "canonicalSuggestionLabel", "canonicalSuggestionButton"]
  static values = { url: String, serverSuggestion: String }

  connect() {
    this.abortController = null
    this.options = []

    if (this.hasServerSuggestionValue && this.serverSuggestionValue.length > 0) {
      this.showCanonicalSuggestion(this.serverSuggestionValue)
    }
  }

  disconnect() {
    clearTimeout(this.searchTimeout)
    clearTimeout(this.hideTimeout)
    this.abortRequest()
  }

  search() {
    clearTimeout(this.searchTimeout)
    clearTimeout(this.hideTimeout)

    const query = this.nameInputTarget.value.trim()

    if (query.length === 0) {
      this.options = []
      this.hideResults()
      this.hideCanonicalSuggestion()
      return
    }

    this.searchTimeout = setTimeout(() => this.fetchOptions(query), 150)
  }

  queueHide() {
    clearTimeout(this.hideTimeout)
    this.hideTimeout = setTimeout(() => this.hideResults(), 150)
  }

  applySuggestion(event) {
    event.preventDefault()

    const canonicalName = event.currentTarget.dataset.name
    if (!canonicalName) return

    this.nameInputTarget.value = canonicalName
    this.nameInputTarget.focus()
    this.hideCanonicalSuggestion()
    this.hideResults()
  }

  choose(event) {
    event.preventDefault()

    const canonicalName = event.currentTarget.dataset.name
    this.nameInputTarget.value = canonicalName
    this.hideCanonicalSuggestion()
    this.hideResults()
    this.nameInputTarget.focus()
  }

  async fetchOptions(query) {
    this.abortRequest()
    this.abortController = new AbortController()

    try {
      const response = await fetch(`${this.urlValue}?q=${encodeURIComponent(query)}`, {
        headers: { Accept: "application/json" },
        signal: this.abortController.signal
      })

      if (!response.ok) return

      const payload = await response.json()
      this.options = payload.options || []
      this.renderResults()
      this.syncCanonicalSuggestion(query)
    } catch (error) {
      if (error.name !== "AbortError") {
        this.options = []
        this.hideResults()
      }
    }
  }

  renderResults() {
    if (this.options.length === 0) {
      this.hideResults()
      return
    }

    this.resultsTarget.innerHTML = this.options.map((option) => `
      <button type="button"
              class="flex w-full items-center justify-between px-4 py-3 text-left text-sm text-slate-700 transition-colors hover:bg-slate-50 dark:text-slate-200 dark:hover:bg-slate-800"
              data-action="mousedown->medication-form#choose"
              data-name="${this.escapeHtml(option.name)}">
        <span class="font-medium">${this.escapeHtml(option.name)}</span>
        <span class="text-xs text-slate-400">usar nome salvo</span>
      </button>
    `).join("")

    this.resultsTarget.classList.remove("hidden")
  }

  syncCanonicalSuggestion(query) {
    const normalizedQuery = this.normalize(query)
    const exactMatch = this.options.find((option) => option.normalized_name === normalizedQuery)

    if (exactMatch && exactMatch.name !== query.trim().replace(/\s+/g, " ")) {
      this.showCanonicalSuggestion(exactMatch.name)
      return
    }

    this.hideCanonicalSuggestion()
  }

  showCanonicalSuggestion(name) {
    this.canonicalSuggestionLabelTarget.textContent = name
    this.canonicalSuggestionButtonTarget.dataset.name = name
    this.canonicalSuggestionTarget.classList.remove("hidden")
  }

  hideCanonicalSuggestion() {
    if (!this.hasCanonicalSuggestionTarget) return

    this.canonicalSuggestionTarget.classList.add("hidden")
    this.canonicalSuggestionButtonTarget.dataset.name = ""
  }

  hideResults() {
    if (!this.hasResultsTarget) return

    this.resultsTarget.classList.add("hidden")
    this.resultsTarget.innerHTML = ""
  }

  abortRequest() {
    this.abortController?.abort()
    this.abortController = null
  }

  normalize(value) {
    return value
      .normalize("NFD")
      .replace(/\p{Diacritic}/gu, "")
      .trim()
      .replace(/\s+/g, " ")
      .toLowerCase()
  }

  escapeHtml(value) {
    return value
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#39;")
  }
}
