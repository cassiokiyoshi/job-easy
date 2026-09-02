import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.dismissOnOutsideClick = this.dismissOnOutsideClick.bind(this)
    this.dismissOnEscape = this.dismissOnEscape.bind(this)

    document.addEventListener("pointerdown", this.dismissOnOutsideClick)
    document.addEventListener("keydown", this.dismissOnEscape)
  }

  disconnect() {
    document.removeEventListener("pointerdown", this.dismissOnOutsideClick)
    document.removeEventListener("keydown", this.dismissOnEscape)
  }

  dismissOnOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.element.removeAttribute("open")
    }
  }

  dismissOnEscape(event) {
    if (event.key !== "Escape" || !this.element.open) return

    this.element.removeAttribute("open")
    this.element.querySelector("summary")?.focus()
  }
}
