import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="reward-condition-form"
export default class extends Controller {
  static targets = ["weekdayField", "dailyStreakField"]

  connect() {
    // 初期表示時に適切なフィールドを表示
    this.toggleFields()
    // peer-checked スタイルを手動で適用（DOM更新後に実行）
    setTimeout(() => {
      this.updatePeerCheckedStyles()
    }, 0)
    
    // Turbo Stream によるフォーム再レンダリング後にスタイルを適用
    this.element.addEventListener('turbo:morph', this.handleTurboMorph.bind(this))
    
    // すべてのラジオボタンにchangeイベントリスナーを追加
    this.addChangeListeners()
  }

  disconnect() {
    this.element.removeEventListener('turbo:morph', this.handleTurboMorph.bind(this))
  }

  handleTurboMorph() {
    setTimeout(() => {
      this.updatePeerCheckedStyles()
    }, 0)
  }

  toggleFields() {
    const selectedConditionType = this.getSelectedConditionType()

    if (selectedConditionType === "weekly") {
      this.showWeekdayField()
      this.hideDailyStreakField()
    } else if (selectedConditionType === "daily_streak") {
      this.hideWeekdayField()
      this.showDailyStreakField()
    } else {
      // 何も選択されていない場合は両方非表示
      this.hideWeekdayField()
      this.hideDailyStreakField()
    }
    
    // フィールド切り替え後にスタイルを更新
    this.updatePeerCheckedStyles()
  }

  getSelectedConditionType() {
    const checkedRadio = this.element.querySelector('input[name*="condition_type"]:checked')
    return checkedRadio ? checkedRadio.value : null
  }

  showWeekdayField() {
    if (this.hasWeekdayFieldTarget) {
      this.weekdayFieldTarget.style.display = "block"
      this.weekdayFieldTarget.classList.remove("hidden")
      // フィールド表示後にスタイルを更新
      setTimeout(() => {
        this.updatePeerCheckedStyles()
      }, 0)
    }
  }

  hideWeekdayField() {
    if (this.hasWeekdayFieldTarget) {
      this.weekdayFieldTarget.style.display = "none"
      this.weekdayFieldTarget.classList.add("hidden")
    }
  }

  showDailyStreakField() {
    if (this.hasDailyStreakFieldTarget) {
      this.dailyStreakFieldTarget.style.display = "block"
      this.dailyStreakFieldTarget.classList.remove("hidden")
      // フィールド表示後にスタイルを更新
      setTimeout(() => {
        this.updatePeerCheckedStyles()
      }, 0)
    }
  }

  hideDailyStreakField() {
    if (this.hasDailyStreakFieldTarget) {
      this.dailyStreakFieldTarget.style.display = "none"
      this.dailyStreakFieldTarget.classList.add("hidden")
    }
  }

  addChangeListeners() {
    // すべてのラジオボタンにchangeイベントリスナーを追加
    const radioButtons = this.element.querySelectorAll('input[type="radio"]')
    radioButtons.forEach(radio => {
      radio.addEventListener('change', () => {
        this.updatePeerCheckedStyles()
      })
    })
  }

  updatePeerCheckedStyles() {
    // すべてのラジオボタンとチェックボックスを取得
    const inputGroups = this.element.querySelectorAll('input[type="radio"], input[type="checkbox"]')
    
    inputGroups.forEach(input => {
      // より確実にカード要素を取得
      let card = input.nextElementSibling
      if (!card) {
        // 親がfield_with_errorsの場合、隣の要素が直接カード
        if (input.parentElement.className.includes('field_with_errors')) {
          const nextElement = input.parentElement.nextElementSibling
          if (nextElement && nextElement.className.includes('border-2')) {
            card = nextElement
          }
        } else {
          // 通常の場合、親のlabelから探す
          card = input.parentElement.querySelector('div[class*="border-2"]')
        }
      }
      
      if (card) {
        if (input.checked) {
          // チェック済みのスタイルを適用
          card.classList.add('border-teal-500', 'bg-teal-100')
          card.classList.remove('border-gray-200')
        } else {
          // 未チェックのスタイルを適用
          card.classList.add('border-gray-200')
          card.classList.remove('border-teal-500', 'bg-teal-100')
        }
      }
    })
  }
}