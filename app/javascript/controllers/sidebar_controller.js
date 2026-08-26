import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggle"]

  connect() {
    this.applyCollapsedState(sessionStorage.getItem("sidebar-collapsed") === "true")
  }

  toggle() {
    const isCollapsed = this.element.classList.toggle("sidebar--collapsed")

    sessionStorage.setItem("sidebar-collapsed", String(isCollapsed))
    this.applyCollapsedState(isCollapsed)
  }

  expand() {
    sessionStorage.setItem("sidebar-collapsed", "false")
    this.applyCollapsedState(false)
  }

  applyCollapsedState(isCollapsed) {
    const pageContent = document.querySelector(".page-content")

    this.element.classList.toggle("sidebar--collapsed", isCollapsed)
    pageContent?.classList.toggle(
      "page-content--sidebar-collapsed",
      isCollapsed
    )

    if (this.hasToggleTarget) {
      this.toggleTarget.setAttribute("aria-expanded", String(!isCollapsed))
      this.toggleTarget.setAttribute(
        "aria-label",
        isCollapsed ? "Expand sidebar" : "Collapse sidebar"
      )
    }
  }
}
