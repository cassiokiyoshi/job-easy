import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="date-input"
// Shows a plain text placeholder, then switches to the native
// datetime-local picker once the field is focused.
export default class extends Controller {
  showPicker() {
    this.element.type = "datetime-local"
  }

  restore() {
    if (!this.element.value) {
      this.element.type = "text"
    }
  }
}
