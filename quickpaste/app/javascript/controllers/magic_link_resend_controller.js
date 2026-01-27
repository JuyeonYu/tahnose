import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["resendButton", "timer"]
  static values = { seconds: Number, suffix: String }

  connect() {
    if (this.secondsValue > 0) {
      this.startCooldown(this.secondsValue)
    }
  }

  startCooldown(seconds) {
    this.remainingSeconds = seconds
    this.updateUI()
    this.timer = setInterval(() => {
      this.remainingSeconds -= 1
      if (this.remainingSeconds <= 0) {
        this.stopCooldown()
        return
      }
      this.updateUI()
    }, 1000)
  }

  stopCooldown() {
    if (this.timer) {
      clearInterval(this.timer)
    }
    this.remainingSeconds = 0
    this.updateUI()
  }

  updateUI() {
    if (this.hasResendButtonTarget) {
      this.resendButtonTarget.disabled = this.remainingSeconds > 0
    }
    if (this.hasTimerTarget) {
      if (this.remainingSeconds > 0) {
        const suffix = this.hasSuffixValue ? this.suffixValue : "s"
        this.timerTarget.textContent = ` ${this.remainingSeconds}${suffix}`
      } else {
        this.timerTarget.textContent = ""
      }
    }
  }
}
