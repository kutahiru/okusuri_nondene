import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.registerServiceWorkerOnly()

    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', () => {
        this.setupNotificationPrompt()
      })
    } else {
      setTimeout(() => {
        this.setupNotificationPrompt()
      }, 500)
    }
  }

  // Service Workerの登録のみを実施
  async registerServiceWorkerOnly() {
    if (!('serviceWorker' in navigator)) {
      return
    }

    try {
      await navigator.serviceWorker.register('/service-worker.js')
    } catch (error) {
      console.error('[PushNotification] Service Worker 登録失敗:', error)
    }
  }

  // 通知許可プロンプトを準備（ユーザーのインタラクション後に実行）
  setupNotificationPrompt() {
    if (Notification.permission === 'granted') {
      // 頻度制限：1日1回のみサーバーに送信
      if (this.shouldCheckSubscription()) {
        this.subscribeToPushNotifications()
      }
      return
    }

    if (Notification.permission === 'denied') {
      return
    }

    // default状態：自動的にプロンプトを表示（3秒後）
    setTimeout(() => this.requestNotificationPermission(), 3000)
  }

  // 通知許可をリクエスト（ユーザー操作から呼ぶ）
  async requestNotificationPermission() {
    try {
      const permission = await Notification.requestPermission()

      if (permission === 'granted') {
        console.log('[PushNotification] 通知許可が与えられました')
        // 手動許可時は制限をバイパス
        await this.subscribeToPushNotifications()
      }
    } catch (error) {
      console.error('[PushNotification] 通知許可リクエストエラー:', error)
    }
  }

  // プッシュ通知に購読（通知許可の後に呼ぶ）
  async subscribeToPushNotifications() {
    if (!('PushManager' in window)) {
      return
    }

    if (Notification.permission !== 'granted') {
      return
    }

    try {
      const registration = await navigator.serviceWorker.ready

      if (!window.vapidPublicKey) {
        console.error('[PushNotification] VAPID パブリックキーが見つかりません')
        return
      }

      const existingSubscription = await registration.pushManager.getSubscription()

      if (existingSubscription) {
        await this.sendSubscriptionToServer(existingSubscription)
        console.log('[PushNotification] 既存購読を更新しました')
      } else {
        const subscription = await registration.pushManager.subscribe({
          userVisibleOnly: true,
          applicationServerKey: this.urlBase64ToUint8Array(window.vapidPublicKey)
        })
        await this.sendSubscriptionToServer(subscription)
        console.log('[PushNotification] 新規購読を作成しました')
      }
    } catch (error) {
      console.error('[PushNotification] プッシュ購読に失敗しました:', error)
    }
  }

  // Base64エンコードされたVAPIDキーをUint8Arrayに変換
  urlBase64ToUint8Array(base64String) {
    const padding = '='.repeat((4 - base64String.length % 4) % 4)
    const base64 = (base64String + padding)
      .replace(/\-/g, '+')
      .replace(/_/g, '/')

    const rawData = window.atob(base64)
    const outputArray = new Uint8Array(rawData.length)

    for (let i = 0; i < rawData.length; ++i) {
      outputArray[i] = rawData.charCodeAt(i)
    }
    return outputArray
  }

  // 購読確認の頻度制限をチェック（1日1回）
  shouldCheckSubscription() {
    const lastCheck = localStorage.getItem('push_subscription_last_check')
    const today = new Date().toDateString()
    
    if (lastCheck === today) {
      return false // 今日既にチェック済み
    }
    
    localStorage.setItem('push_subscription_last_check', today)
    return true
  }

  // プッシュ購読情報をサーバーに送信
  // サーバー側で購読情報を保存し、プッシュ通知送信時に使用される
  async sendSubscriptionToServer(subscription) {
    try {
      // CSRF保護のためのトークンを取得
      const csrfToken = document.querySelector('[name="csrf-token"]')?.content

      if (!csrfToken) {
        console.error('[PushNotification] CSRF トークンが見つかりません')
        return
      }

      // 購読情報をサーバーに送信（10秒でタイムアウト）
      const response = await fetch('/push_subscriptions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken
        },
        body: JSON.stringify({
          subscription: subscription.toJSON()
        }),
        signal: AbortSignal.timeout(10000)
      })

      if (!response.ok) {
        const errorText = await response.text()
        throw new Error(`サーバー応答エラー: ${response.status} - ${errorText}`)
      }
    } catch (error) {
      if (error.name === 'AbortError') {
        console.error('[PushNotification] 購読情報送信がタイムアウトしました')
      } else {
        console.error('[PushNotification] サーバーへの購読情報送信エラー:', error.message)
      }
    }
  }
}