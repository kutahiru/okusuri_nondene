// app/javascript/controllers/mobile_menu_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "button", "openIcon", "closeIcon"]

  connect() {
    // ウィンドウリサイズ時の処理
    this.handleResize = this.handleResize.bind(this)
    window.addEventListener('resize', this.handleResize)

    // 外部クリック時の処理
    this.handleOutsideClick = this.handleOutsideClick.bind(this)
    document.addEventListener('click', this.handleOutsideClick)

    // ESCキー押下時の処理
    this.handleEscapeKey = this.handleEscapeKey.bind(this)
    document.addEventListener('keydown', this.handleEscapeKey)
  }

  disconnect() {
    window.removeEventListener('resize', this.handleResize)
    document.removeEventListener('click', this.handleOutsideClick)
    document.removeEventListener('keydown', this.handleEscapeKey)
  }

  toggle() {
    const isOpen = !this.menuTarget.classList.contains('hidden')

    if (isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.menuTarget.classList.remove('hidden')
    this.openIconTarget.classList.add('hidden')
    this.closeIconTarget.classList.remove('hidden')
    this.buttonTarget.setAttribute('aria-expanded', 'true')
    this.buttonTarget.setAttribute('aria-label', 'メニューを閉じる')
  }

  close() {
    this.menuTarget.classList.add('hidden')
    this.openIconTarget.classList.remove('hidden')
    this.closeIconTarget.classList.add('hidden')
    this.buttonTarget.setAttribute('aria-expanded', 'false')
    this.buttonTarget.setAttribute('aria-label', 'メニューを開く')
  }

  closeOnMobile() {
    // モバイル画面でのみメニューを閉じる
    if (window.innerWidth < 1024) {
      this.close()
    }
  }

  handleResize() {
    // デスクトップサイズになったらメニューを閉じる
    if (window.innerWidth >= 1024) {
      this.close()
    }
  }

  handleOutsideClick(event) {
    // メニューが開いている場合のみ処理
    if (this.menuTarget.classList.contains('hidden')) return
    
    // クリックされた要素がナビゲーション内部でない場合、メニューを閉じる
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  handleEscapeKey(event) {
    if (event.key === 'Escape' && !this.menuTarget.classList.contains('hidden')) {
      this.close()
    }
  }
}