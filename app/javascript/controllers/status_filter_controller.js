import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "card"]

  filter() {
    const selectedStatus = this.selectTarget.value
    let visibleCard = null

    this.cardTargets.forEach((card) => {
      const shouldShow =
        selectedStatus === "all" ||
        card.dataset.status === selectedStatus

      card.hidden = !shouldShow

      if (shouldShow && selectedStatus !== "all") {
        visibleCard = card
      }
    })

    const isFiltered = selectedStatus !== "all"
    const hasSingleApplication =
      visibleCard?.classList.contains("task-status-card--single")

    this.element.classList.toggle(
      "application-tasks--filtered",
      isFiltered
    )

    this.element.classList.toggle(
      "application-tasks--filtered-single",
      isFiltered && hasSingleApplication
    )
  }
}
