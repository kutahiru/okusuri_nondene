import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="reward-condition-form"
export default class extends Controller {
  static targets = ["weekdayField", "dailyStreakField"]

  connect() {
    // 初期表示時に適切なフィールドを表示
    this.toggleFields()
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
  }

  getSelectedConditionType() {
    const checkedRadio = this.element.querySelector('input[name*="condition_type"]:checked')
    return checkedRadio ? checkedRadio.value : null
  }

  showWeekdayField() {
    if (this.hasWeekdayFieldTarget) {
      this.weekdayFieldTarget.style.display = "block"
      this.weekdayFieldTarget.classList.remove("hidden")
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
    }
  }

  hideDailyStreakField() {
    if (this.hasDailyStreakFieldTarget) {
      this.dailyStreakFieldTarget.style.display = "none"
      this.dailyStreakFieldTarget.classList.add("hidden")
    }
  }
}