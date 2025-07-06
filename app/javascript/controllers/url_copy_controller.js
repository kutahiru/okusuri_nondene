import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "button"]

  copy() {
    const input = this.inputTarget
    const button = this.buttonTarget
    
    // テキストを選択
    input.select()
    input.setSelectionRange(0, 99999) // モバイル対応
    
    try {
      // 古いブラウザー対応のコピー方式
      document.execCommand('copy')
      
      // 成功時のフィードバック
      this.showSuccess(button)
    } catch (err) {
      console.error('コピーに失敗しました:', err)
      // エラー時のフィードバック
      this.showError(button)
    }
  }

  showSuccess(button) {
    const originalText = button.textContent
    button.textContent = 'コピー済み'
    button.classList.remove('bg-teal-600', 'hover:bg-teal-700')
    button.classList.add('bg-teal-700')
    
    setTimeout(() => {
      button.textContent = originalText
      button.classList.remove('bg-teal-700')
      button.classList.add('bg-teal-600', 'hover:bg-teal-700')
    }, 2000)
  }

  showError(button) {
    const originalText = button.textContent
    button.textContent = 'エラー'
    button.classList.remove('bg-teal-600', 'hover:bg-teal-700')
    button.classList.add('bg-red-600')
    
    setTimeout(() => {
      button.textContent = originalText
      button.classList.remove('bg-red-600')
      button.classList.add('bg-teal-600', 'hover:bg-teal-700')
    }, 2000)
  }
}