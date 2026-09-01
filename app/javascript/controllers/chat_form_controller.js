import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  submitOnEnter(event) {
    if (event.target.tagName !== "TEXTAREA") return
    if (event.key !== "Enter") return
    if (event.shiftKey) return
    if (event.isComposing) return

    event.preventDefault()
    this.element.requestSubmit()
  }
}
