let lastPagePath = null

function canTrack() {
  return typeof window !== "undefined" &&
    window.gaMeasurementId &&
    typeof window.gtag === "function"
}

function currentPath() {
  return window.location.pathname + window.location.search
}

function trackPageView() {
  if (!canTrack()) return

  const path = currentPath()
  if (path === lastPagePath) return

  lastPagePath = path
  window.gtag("event", "page_view", {
    page_location: window.location.href,
    page_path: path,
    page_title: document.title
  })
}

window.qpTrack = function(eventName, params = {}) {
  if (!canTrack()) return
  window.gtag("event", eventName, params)
}

// Initial load
trackPageView()

// Turbo navigation
document.addEventListener("turbo:load", trackPageView)
