import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["viewport", "topButton", "bottomButton"]

  connect() {
    this.observer = new MutationObserver(() => {
      this.scrollToBottom()
      this.updateButtons()
    })
    this.observer.observe(this.viewportTarget, { childList: true })
    this.resizeObserver = new ResizeObserver(() => this.updateButtons())
    this.resizeObserver.observe(this.viewportTarget)

    requestAnimationFrame(() => {
      this.viewportTarget.scrollTop = this.viewportTarget.scrollHeight
      this.updateButtons()
    })
  }

  disconnect() {
    this.observer.disconnect()
    this.resizeObserver.disconnect()
  }

  scrollToTop() {
    this.viewportTarget.scrollTo({ top: 0, behavior: "auto" })
  }

  scrollToBottom() {
    this.viewportTarget.scrollTo({
      top: this.viewportTarget.scrollHeight,
      behavior: "auto"
    })
  }

  updateButtons() {
    const viewport = this.viewportTarget
    const distanceFromBottom = viewport.scrollHeight - viewport.scrollTop - viewport.clientHeight
    const hasOverflow = viewport.scrollHeight > viewport.clientHeight

    this.topButtonTarget.hidden = !hasOverflow || viewport.scrollTop <= 8
    this.bottomButtonTarget.hidden = !hasOverflow || distanceFromBottom <= 8
  }
}
