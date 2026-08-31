import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.move = this.move.bind(this)
    this.stop = this.stop.bind(this)

    const savedWidth = Number(localStorage.getItem("applicationChatPanelWidth"))

    if (savedWidth && window.innerWidth > 600) {
      this.setWidth(savedWidth)
    } else {
      this.syncPageOffset()
    }
  }

  disconnect() {
    document.body.classList.remove("application-chat-is-resizing")
    this.removePointerListeners()
  }

  start(event) {
    if (event.button !== 0) return

    event.preventDefault()

    this.startX = event.clientX
    this.startWidth = this.element.getBoundingClientRect().width

    document.body.classList.add("application-chat-is-resizing")
    window.addEventListener("pointermove", this.move)
    window.addEventListener("pointerup", this.stop)
  }

  move(event) {
    const distance = this.startX - event.clientX

    this.setWidth(this.startWidth + distance)
  }

  stop() {
    this.saveWidth()

    document.body.classList.remove("application-chat-is-resizing")
    this.removePointerListeners()
  }

  resizeWithKeyboard(event) {
    if (!["ArrowLeft", "ArrowRight"].includes(event.key)) return

    event.preventDefault()

    const currentWidth = this.element.getBoundingClientRect().width
    const change = event.key === "ArrowLeft" ? 20 : -20

    this.setWidth(currentWidth + change)
    this.saveWidth()
  }

  setWidth(width) {
    const minimumWidth = 320
    const maximumWidth = window.innerWidth - 24
    const newWidth = Math.min(Math.max(width, minimumWidth), maximumWidth)

    this.element.style.width = `${newWidth}px`
    this.syncPageOffset()
  }

  syncPageOffset() {
    if (!document.body.classList.contains("application-chat-is-open")) return

    document.body.style.setProperty(
      "--application-chat-panel-width",
      `${Math.round(this.element.getBoundingClientRect().width)}px`
    )
  }

  saveWidth() {
    localStorage.setItem(
      "applicationChatPanelWidth",
      Math.round(this.element.getBoundingClientRect().width)
    )
  }

  removePointerListeners() {
    window.removeEventListener("pointermove", this.move)
    window.removeEventListener("pointerup", this.stop)
  }
}
