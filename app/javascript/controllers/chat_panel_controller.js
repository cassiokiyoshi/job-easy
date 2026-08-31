import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "backdrop", "trigger", "closeButton"]
  static values = {
    open: Boolean
  }

  connect() {
    this.handleKeydown = this.handleKeydown.bind(this)

    if (this.openValue) {
      requestAnimationFrame(() => this.open())
    }
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleKeydown)
    document.body.classList.remove("application-chat-is-open")
    document.body.style.removeProperty("--application-chat-panel-width")
  }

  open() {
    this.panelTarget.hidden = false
    this.backdropTarget.hidden = window.innerWidth > 600
    this.triggerTarget.setAttribute("aria-expanded", "true")
    document.body.style.setProperty(
      "--application-chat-panel-width",
      `${Math.round(this.panelTarget.getBoundingClientRect().width)}px`
    )
    document.body.classList.add("application-chat-is-open")
    document.addEventListener("keydown", this.handleKeydown)
    this.setOpenParameter()

    this.closeButtonTarget.focus()
  }

  close() {
    this.panelTarget.hidden = true
    this.backdropTarget.hidden = true
    this.triggerTarget.setAttribute("aria-expanded", "false")
    document.body.classList.remove("application-chat-is-open")
    document.body.style.removeProperty("--application-chat-panel-width")
    document.removeEventListener("keydown", this.handleKeydown)
    this.removeOpenParameter()

    this.triggerTarget.focus()
  }

  handleKeydown(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  setOpenParameter() {
    const url = new URL(window.location.href)

    url.searchParams.set("chat", "open")
    window.history.replaceState(window.history.state, "", url)
  }

  removeOpenParameter() {
    const url = new URL(window.location.href)

    url.searchParams.delete("chat")
    window.history.replaceState(window.history.state, "", url)
  }
}
