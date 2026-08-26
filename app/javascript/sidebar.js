document.addEventListener("click", (event) => {
  const toggleButton = event.target.closest("#sidebar-toggle")

  if (!toggleButton) return

  const sidebar = document.querySelector("#sidebar")
  const pageContent = document.querySelector(".page-content")

  if (!sidebar || !pageContent) return

  const isCollapsed = sidebar.classList.toggle("sidebar--collapsed")

  pageContent.classList.toggle(
    "page-content--sidebar-collapsed",
    isCollapsed
  )

  toggleButton.setAttribute("aria-expanded", String(!isCollapsed))
  toggleButton.setAttribute(
    "aria-label",
    isCollapsed ? "Expand sidebar" : "Collapse sidebar"
  )
})
