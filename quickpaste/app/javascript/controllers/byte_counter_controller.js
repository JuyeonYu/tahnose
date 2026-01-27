import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "output"]
  static values = { max: Number }

  connect() {
    this.update()
  }

  update() {
    const text = this.inputTarget.value || ""
    const bytes = new TextEncoder().encode(text).length
    const unit = this.outputTarget.dataset.byteCounterUnit || ""
    this.outputTarget.textContent = `${bytes} / ${this.maxValue} ${unit}`.trim()
  }
}
