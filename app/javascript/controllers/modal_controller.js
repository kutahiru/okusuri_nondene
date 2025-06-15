import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  static targets = ["backdrop", "content"]

  connect() {
    // モーダルを表示
    this.show()
    // ESCキーでモーダルを閉じる
    this.boundKeyHandler = this.handleKeydown.bind(this)
    document.addEventListener("keydown", this.boundKeyHandler)
    // body要素のスクロールを無効にする
    document.body.classList.add("overflow-hidden")
  }

  disconnect() {
    // イベントリスナーを削除
    document.removeEventListener("keydown", this.boundKeyHandler)
    // body要素のスクロールを有効にする
    document.body.classList.remove("overflow-hidden")
  }

  show() {
    // モーダルを表示（フェードイン効果付き）
    this.element.classList.remove("hidden", "pointer-events-none")
    // this.element.classList.add("opacity-100", "pointer-events-auto")

    // コンテンツをスケールアップ
    if (this.hasContentTarget) {
      this.contentTarget.classList.remove("scale-95")
      this.contentTarget.classList.add("scale-100")
    }
  }

  hide() {
    // モーダルを非表示（フェードアウト効果付き）
    // this.element.classList.remove("opacity-100", "pointer-events-auto")
    this.element.classList.add("hidden", "pointer-events-none")

    // コンテンツをスケールダウン
    if (this.hasContentTarget) {
      this.contentTarget.classList.remove("scale-100")
      this.contentTarget.classList.add("scale-95")
    }

    // アニメーション完了後にモーダルを削除
    setTimeout(() => {
      this.element.remove()
    }, 300) // transition-all duration-300に合わせる
  }

  // アクション定義：保存成功時にモーダルを閉じる
  close(event) {
    // event.detail.successは、レスポンスが成功ならtrueを返す
    // バリデーションエラー時はモーダルを閉じたくないので、成功時のみ閉じる
    if (event.detail.success) {
      this.hide()
    }
  }

  // 背景クリックでモーダルを閉じる
  backdropClick(event) {
    if (event.target === this.backdropTarget) {
      this.hide()
    }
  }

  // ESCキーでモーダルを閉じる
  handleKeydown(event) {
    if (event.key === "Escape") {
      this.hide()
    }
  }
}
