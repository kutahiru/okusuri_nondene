import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { 
    autoHide: Boolean,
    hideDelay: Number
  }

  connect() {
    if (this.autoHideValue) {
      this.scheduleHide()
    }
  }

  hide() {
    this.element.style.display = 'none'
  }

  scheduleHide() {
    clearTimeout(this.hideTimeout)
    const delay = this.hideDelayValue || 5000
    this.hideTimeout = setTimeout(() => {
      this.hide()
    }, delay)
  }
}