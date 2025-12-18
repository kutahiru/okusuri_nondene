import { Controller } from "@hotwired/stimulus"

// Turbo Nativeとの通信を管理するコントローラー
export default class extends Controller {
  connect() {
    // Turbo Nativeアプリかどうかを判定
    this.isTurboNative = /Turbo Native/.test(navigator.userAgent)

    if (this.isTurboNative) {
      console.log("Turbo Native app detected")
      this.setupNativeBridge()
    }
  }

  setupNativeBridge() {
    // ネイティブアプリからメッセージを受信
    document.addEventListener("turbo:load", () => {
      this.notifyPageLoad()
    })
  }

  // ページロードをネイティブアプリに通知
  notifyPageLoad() {
    if (window.webkit?.messageHandlers?.pageLoaded) {
      // iOS
      window.webkit.messageHandlers.pageLoaded.postMessage({
        title: document.title,
        url: window.location.href
      })
    } else if (window.NativeApp?.onPageLoaded) {
      // Android
      window.NativeApp.onPageLoaded(document.title, window.location.href)
    }
  }

  // ネイティブアプリにメッセージを送信
  sendMessage(name, data = {}) {
    if (window.webkit?.messageHandlers?.[name]) {
      // iOS
      window.webkit.messageHandlers[name].postMessage(data)
    } else if (window.NativeApp?.[name]) {
      // Android
      window.NativeApp[name](JSON.stringify(data))
    }
  }

  // アプリバーのタイトルを設定
  setTitle(event) {
    const title = event.params?.title || document.title
    this.sendMessage("setTitle", { title })
  }

  // ネイティブのアラートを表示
  showNativeAlert(message, title = "通知") {
    this.sendMessage("showAlert", { title, message })
  }

  // ネイティブの確認ダイアログを表示
  showNativeConfirm(message, title = "確認") {
    this.sendMessage("showConfirm", { title, message })
  }
}
