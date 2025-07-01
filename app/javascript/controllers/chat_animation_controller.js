import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message", "heroSection", "featuresSection", "chatSection", "switchButton"]

  connect() {
    this.currentMessageIndex = 0
    this.isAutoPlaying = true
    this.timeouts = []
    this.animateMessages()
  }

  disconnect() {
    // コンポーネント破棄時にタイマーをクリア
    this.timeouts.forEach(timeout => clearTimeout(timeout))
  }

  animateMessages() {
    this.messageTargets.forEach((message, index) => {
      const delay = parseInt(message.dataset.delay) || 0

      const timeout = setTimeout(() => {
        if (this.isAutoPlaying) {
          this.showMessage(message)
          this.currentMessageIndex = index + 1
        }
      }, delay)

      this.timeouts.push(timeout)
    })

    // スイッチボタンをアニメーション
    if (this.hasSwitchButtonTarget) {
      const buttonDelay = parseInt(this.switchButtonTarget.dataset.delay) || 0
      const timeout = setTimeout(() => {
        if (this.isAutoPlaying) {
          this.switchButtonTarget.style.transition = "all 1.5s ease-out"
          this.switchButtonTarget.classList.remove("opacity-0", "translate-y-4")
          this.switchButtonTarget.classList.add("opacity-100", "translate-y-0")
          this.currentMessageIndex = this.messageTargets.length + 1
        }
      }, buttonDelay)

      this.timeouts.push(timeout)
    }
  }

  showMessage(message) {
    message.style.transition = "all 1.5s ease-out"
    message.classList.remove("opacity-0", "translate-y-4")
    message.classList.add("opacity-100", "translate-y-0")
  }

  // クリックで次のメッセージを表示
  nextMessage(event) {
    // switchButtonがクリックされた場合は何もしない（独自のアクションを実行）
    if (event.target.closest('[data-action*="switchToHero"]')) {
      return
    }

    // 自動再生を停止
    this.isAutoPlaying = false
    this.timeouts.forEach(timeout => clearTimeout(timeout))
    this.timeouts = []

    // 次のメッセージを表示
    if (this.currentMessageIndex < this.messageTargets.length) {
      const nextMessage = this.messageTargets[this.currentMessageIndex]
      this.showMessage(nextMessage)
      this.currentMessageIndex++
    } else if (this.currentMessageIndex === this.messageTargets.length && this.hasSwitchButtonTarget) {
      // スイッチボタンを表示
      this.switchButtonTarget.style.transition = "all 1.5s ease-out"
      this.switchButtonTarget.classList.remove("opacity-0", "translate-y-4")
      this.switchButtonTarget.classList.add("opacity-100", "translate-y-0")
      this.currentMessageIndex++
    } else if (this.currentMessageIndex > this.messageTargets.length) {
      // 全て表示済みの場合はheroセクションに移行
      this.switchToHero()
    }
  }

  switchToHero() {
    // チャットセクションをフェードアウト
    if (this.hasChatSectionTarget) {
      this.chatSectionTarget.style.transition = "all 1s ease-out"
      this.chatSectionTarget.classList.add("opacity-0", "translate-y-8")

      // チャットセクション非表示完了後にheroSectionを表示
      setTimeout(() => {
        this.chatSectionTarget.style.display = "none"

        if (this.hasHeroSectionTarget) {
          this.heroSectionTarget.classList.remove("hidden")
          // 少し待ってからアニメーション開始
          setTimeout(() => {
            this.heroSectionTarget.style.transition = "all 1.2s ease-out"
            this.heroSectionTarget.classList.remove("opacity-0", "translate-y-8")
            this.heroSectionTarget.classList.add("opacity-100", "translate-y-0")
          }, 100)
        }
      }, 1000) // フェードアウト完了を待つ
    }

    // featuresSection も少し遅れて表示
    setTimeout(() => {
      if (this.hasFeaturesSectionTarget) {
        this.featuresSectionTarget.classList.remove("hidden")
        // 少し待ってからアニメーション開始
        setTimeout(() => {
          this.featuresSectionTarget.style.transition = "all 1.2s ease-out"
          this.featuresSectionTarget.classList.remove("opacity-0", "translate-y-8")
          this.featuresSectionTarget.classList.add("opacity-100", "translate-y-0")
        }, 100)
      }
    }, 2200) // heroSection表示から少し遅れて
  }
}