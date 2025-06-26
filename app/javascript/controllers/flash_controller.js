import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["messageContainer"]
  static values = { 
    autoHide: Boolean,
    hideDelay: Number
  }

  connect() {
    if (this.autoHideValue) {
      this.scheduleHide()
    }
  }

  showMessage(messageType, message) {
    const messageHtml = this.createMessageHtml(messageType, message)
    this.messageContainerTarget.innerHTML = messageHtml
    this.messageContainerTarget.style.display = 'block'

    if (this.autoHideValue) {
      this.scheduleHide()
    }
  }

  hide() {
    this.messageContainerTarget.style.display = 'none'
    this.messageContainerTarget.innerHTML = ''
  }

  scheduleHide() {
    clearTimeout(this.hideTimeout)
    const delay = this.hideDelayValue || 5000
    this.hideTimeout = setTimeout(() => {
      this.hide()
    }, delay)
  }

  createMessageHtml(messageType, message) {
    const messageConfigs = {
      success: {
        bgColor: 'bg-emerald-500',
        textColor: 'text-emerald-500',
        icon: `<path d="M20 3.33331C10.8 3.33331 3.33337 10.8 3.33337 20C3.33337 29.2 10.8 36.6666 20 36.6666C29.2 36.6666 36.6667 29.2 36.6667 20C36.6667 10.8 29.2 3.33331 20 3.33331ZM16.6667 28.3333L8.33337 20L10.6834 17.65L16.6667 23.6166L29.3167 10.9666L31.6667 13.3333L16.6667 28.3333Z" />`,
        titleKey: '成功'
      },
      error: {
        bgColor: 'bg-red-500',
        textColor: 'text-red-500',
        icon: `<path d="M20 3.36667C10.8167 3.36667 3.3667 10.8167 3.3667 20C3.3667 29.1833 10.8167 36.6333 20 36.6333C29.1834 36.6333 36.6334 29.1833 36.6334 20C36.6334 10.8167 29.1834 3.36667 20 3.36667ZM19.1334 33.3333V22.9H13.3334L21.6667 6.66667V17.1H27.25L19.1334 33.3333Z" />`,
        titleKey: 'エラー'
      },
      info: {
        bgColor: 'bg-blue-500',
        textColor: 'text-blue-500',
        icon: `<path d="M20 3.33331C10.8 3.33331 3.33337 10.8 3.33337 20C3.33337 29.2 10.8 36.6666 20 36.6666C29.2 36.6666 36.6667 29.2 36.6667 20C36.6667 10.8 29.2 3.33331 20 3.33331ZM21.6667 28.3333H18.3334V25H21.6667V28.3333ZM21.6667 21.6666H18.3334V11.6666H21.6667V21.6666Z" />`,
        titleKey: '情報'
      },
      warning: {
        bgColor: 'bg-yellow-400',
        textColor: 'text-yellow-400',
        icon: `<path d="M20 3.33331C10.8 3.33331 3.33337 10.8 3.33337 20C3.33337 29.2 10.8 36.6666 20 36.6666C29.2 36.6666 36.6667 29.2 36.6667 20C36.6667 10.8 29.2 3.33331 20 3.33331ZM21.6667 28.3333H18.3334V25H21.6667V28.3333ZM21.6667 21.6666H18.3334V11.6666H21.6667V21.6666Z" />`,
        titleKey: '警告'
      }
    }

    const config = messageConfigs[messageType] || messageConfigs.info

    return `
      <div class="my-2">
        <div class="flex w-full max-w-sm overflow-hidden bg-white rounded-lg shadow-md">
          <div class="flex items-center justify-center w-12 ${config.bgColor}">
            <svg class="w-6 h-6 text-white fill-current" viewBox="0 0 40 40" xmlns="http://www.w3.org/2000/svg">
              ${config.icon}
            </svg>
          </div>
          <div class="px-4 py-2 -mx-3">
            <div class="mx-3">
              <span class="font-semibold ${config.textColor}">${config.titleKey}</span>
              <p class="text-sm text-gray-600">${message}</p>
            </div>
          </div>
        </div>
      </div>
    `
  }
}