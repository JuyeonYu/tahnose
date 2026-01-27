import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "readOnce",
    "passwordToggle",
    "passwordFields",
    "passwordInput",
    "passwordConfirmInput",
    "warning",
    "recommended"
  ]

  connect() {
    this.syncPasswordFields()
  }

  toggleReadOnce() {
    if (this.readOnceTarget.checked && !this.passwordToggleTarget.checked) {
      this.passwordToggleTarget.checked = true
    }
    this.syncPasswordFields()
  }

  togglePassword() {
    this.syncPasswordFields()
  }

  syncPasswordFields() {
    const enabled = this.passwordToggleTarget.checked
    const showAdvisory = this.readOnceTarget.checked
    this.passwordFieldsTarget.hidden = !enabled
    this.passwordInputTarget.disabled = !enabled
    this.passwordConfirmInputTarget.disabled = !enabled

    if (this.hasWarningTarget) {
      this.warningTarget.hidden = !showAdvisory
    }

    if (this.hasRecommendedTarget) {
      this.recommendedTarget.hidden = !showAdvisory
    }

    if (!enabled) {
      this.passwordInputTarget.value = ""
      this.passwordConfirmInputTarget.value = ""
    }
  }
}
