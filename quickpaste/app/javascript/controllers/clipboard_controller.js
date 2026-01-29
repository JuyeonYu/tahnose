import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "button"]
  static values = {
    copyLabel: String,
    copiedLabel: String,
    pasteId: Number,
    bodyBytes: Number,
    isLoggedIn: Boolean
  }

  copy() {
    const text = this.contentTarget.textContent

    if (navigator.clipboard && window.isSecureContext) {
      navigator.clipboard.writeText(text).then(() => {
        this.indicate()
        this.trackCopy()
      })
      return
    }

    const textarea = document.createElement("textarea")
    textarea.value = text
    textarea.setAttribute("readonly", "")
    textarea.style.position = "fixed"
    textarea.style.opacity = "0"
    document.body.appendChild(textarea)
    textarea.select()
    document.execCommand("copy")
    textarea.remove()
    this.indicate()
    this.trackCopy()
  }

  indicate() {
    const original = this.buttonTarget.textContent
    const copiedLabel = this.hasCopiedLabelValue ? this.copiedLabelValue : "copied"
    this.buttonTarget.textContent = copiedLabel
    clearTimeout(this.resetTimer)
    this.resetTimer = setTimeout(() => {
      const copyLabel = this.hasCopyLabelValue ? this.copyLabelValue : original
      this.buttonTarget.textContent = copyLabel
    }, 1200)
  }

  trackCopy() {
    if (!window.GA4 || typeof window.GA4.event !== "function") return

    window.GA4.event("copy_clicked", {
      paste_id: this.hasPasteIdValue ? this.pasteIdValue : null,
      body_bytes: this.hasBodyBytesValue ? this.bodyBytesValue : null,
      copy_target: "body",
      is_logged_in: this.hasIsLoggedInValue ? this.isLoggedInValue : false
    })
  }
}
