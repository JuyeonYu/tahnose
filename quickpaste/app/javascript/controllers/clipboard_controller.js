import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "button"]
  static values = { copyLabel: String, copiedLabel: String }

  copy() {
    const text = this.contentTarget.textContent

    if (navigator.clipboard && window.isSecureContext) {
      navigator.clipboard.writeText(text).then(() => this.indicate())
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
}
