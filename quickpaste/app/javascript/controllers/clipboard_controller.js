import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "button"]

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
    this.buttonTarget.textContent = "copied"
    clearTimeout(this.resetTimer)
    this.resetTimer = setTimeout(() => {
      this.buttonTarget.textContent = original
    }, 1200)
  }
}
