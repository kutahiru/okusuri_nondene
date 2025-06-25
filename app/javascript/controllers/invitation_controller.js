import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["alert", "message"]

  async generate(event) {
    event.preventDefault()

    const form = event.target.closest('form')

    try {
      const response = await fetch(form.action, {
        method: 'POST',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
          'Accept': 'application/json'
        }
      })

      const data = await response.json()

      if (data.success) {
        await navigator.clipboard.writeText(data.invitation_link)
        this.showMessage('招待リンクをクリップボードにコピーしました')
      }
    } catch (error) {
      console.error('Error:', error)
    }
  }

  showMessage(text) {
    this.messageTarget.textContent = text
    this.alertTarget.classList.remove('hidden')

    setTimeout(() => {
      this.alertTarget.classList.add('hidden')
    }, 3000)
  }
}