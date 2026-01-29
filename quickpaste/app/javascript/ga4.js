function safeParseJSON(value) {
  if (!value) return {}
  try {
    return JSON.parse(value)
  } catch {
    return {}
  }
}

function storageAvailable() {
  try {
    const testKey = "__ga4_test__"
    sessionStorage.setItem(testKey, "1")
    sessionStorage.removeItem(testKey)
    return true
  } catch {
    return false
  }
}

const canUseStorage = storageAvailable()

function dedupeKey(eventName, params, nonce) {
  const pasteId = params && params.paste_id ? params.paste_id : ""
  return `ga4:${eventName}:${window.location.pathname}:${pasteId}:${nonce || ""}`
}

function alreadySent(key) {
  if (!canUseStorage) return false
  return sessionStorage.getItem(key) === "1"
}

function markSent(key) {
  if (!canUseStorage) return
  sessionStorage.setItem(key, "1")
}

function emitEvent(eventName, params = {}, options = {}) {
  if (!eventName) return

  const dedupe = options.dedupe !== false
  if (dedupe) {
    const key = dedupeKey(eventName, params, options.nonce)
    if (alreadySent(key)) return
    markSent(key)
  }

  if (typeof window.gtag === "function") {
    window.gtag("event", eventName, params)
    return
  }

  console.log("[GA4]", eventName, params)
}

function firePageEvents() {
  const marker = document.getElementById("ga-marker")
  if (!marker) return

  const eventName = marker.dataset.gaEvent
  if (!eventName) return

  const params = safeParseJSON(marker.dataset.gaParams)
  const nonce = marker.dataset.gaNonce
  const gaParam = new URLSearchParams(window.location.search).get("ga")

  if (gaParam === "paste_created") {
    emitEvent("paste_created", params, { nonce })
  }

  emitEvent(eventName, params, { nonce })
}

window.GA4 = {
  event: (eventName, params = {}, options = {}) => emitEvent(eventName, params, options)
}

firePageEvents()
document.addEventListener("turbo:load", firePageEvents)
