import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card", "column"]

  dragStart(event) {
    const card = event.currentTarget

    this.draggedCard = card
    card.classList.add("application-card--dragging")

    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/plain", card.dataset.applicationId)
  }

  dragEnd() {
    this.draggedCard?.classList.remove("application-card--dragging")
    this.clearDropTargets()
    this.draggedCard = null
  }

  dragOver(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = "move"

    event.currentTarget.classList.add("status-column--drag-over")
  }

  dragLeave(event) {
    if (!event.currentTarget.contains(event.relatedTarget)) {
      event.currentTarget.classList.remove("status-column--drag-over")
    }
  }

  async drop(event) {
    event.preventDefault()
    event.stopPropagation()

    const column = event.currentTarget
    const newStatus = column.dataset.status
    const card = this.draggedCard

    this.clearDropTargets()

    if (!card || card.dataset.status === newStatus) return

    card.classList.add("application-card--updating")

    try {
      const response = await fetch(card.dataset.updateUrl, {
        method: "PATCH",
        headers: {
          "Accept": "text/html",
          "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
        },
        body: new URLSearchParams({
          "job_application[status]": newStatus
        })
      })

      if (!response.ok) {
        throw new Error(`Status update failed with ${response.status}`)
      }

      window.location.reload()
    } catch (error) {
      card.classList.remove("application-card--updating")
      console.error(error)
      window.alert("The application status could not be updated.")
    }
  }

  clearDropTargets() {
    this.columnTargets.forEach((column) => {
      column.classList.remove("status-column--drag-over")
    })
  }
}
