import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message", "heroSection", "featuresSection", "chatSection", "switchButton"]

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

    // スイッチボタンをアニメーション
    if (this.hasSwitchButtonTarget) {
      const buttonDelay = parseInt(this.switchButtonTarget.dataset.delay) || 0
      setTimeout(() => {
        this.switchButtonTarget.style.transition = "all 1.5s ease-out"
        this.switchButtonTarget.classList.remove("opacity-0", "translate-y-4")
        this.switchButtonTarget.classList.add("opacity-100", "translate-y-0")
      }, buttonDelay)
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