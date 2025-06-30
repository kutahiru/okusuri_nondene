import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message"]

  connect() {
    this.animateMessages()
  }

  animateMessages() {
    this.messageTargets.forEach((message) => {
      const delay = parseInt(message.dataset.delay) || 0

      setTimeout(() => {
        message.style.transition = "all 1.5s ease-out"
        message.classList.remove("opacity-0", "translate-y-4")
        message.classList.add("opacity-100", "translate-y-0")
      }, delay)
    })
  }
}