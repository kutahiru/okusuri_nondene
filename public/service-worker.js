// Service Worker for Web Push Notifications

/**
 * プッシュ通知を受信した時の処理
 * サーバーからプッシュメッセージが送信された際に実行される
 */
self.addEventListener('push', function(event) {
  console.log('プッシュイベントを受信しました:', event);

  // プッシュデータが存在しない場合は処理を終了
  if (!event.data) {
    console.log('プッシュデータがありません');
    return;
  }

  try {
    // プッシュデータをまず文字列として取得してログ出力
    const rawData = event.data.text();
    console.log('受信した生データ:', rawData);

    // プッシュデータをJSONとして解析
    const data = JSON.parse(rawData);

    // 通知オプションを設定
    const options = {
      body: data.body || 'お薬の時間です',
      icon: '/favicon.ico',
      badge: '/favicon.ico',
      tag: data.tag || 'medication-reminder',
      data: {
        url: data.url || '/',
        ...data
      },
      actions: data.actions || [
        {
          action: 'view',
          title: '確認する'
        },
        {
          action: 'close',
          title: '閉じる'
        }
      ]
    };

    // ブラウザ通知を表示
    event.waitUntil(
      self.registration.showNotification(
        data.title || 'おくすり飲んでね',
        options
      )
    );
  } catch (error) {
    console.error('プッシュデータの解析エラー:', error);

    // データ解析に失敗した場合のフォールバック通知
    event.waitUntil(
      self.registration.showNotification('おくすり飲んでね', {
        body: 'お薬の時間です',
        icon: '/favicon.ico',
        tag: 'medication-reminder'
      })
    );
  }
});

/**
 * 通知がクリックされた時の処理
 * ユーザーが通知をクリックした際に実行される
 */
self.addEventListener('notificationclick', function(event) {
  console.log('通知がクリックされました:', event);

  // 通知を閉じる
  event.notification.close();

  // 「閉じる」アクションが選択された場合は何もしない
  if (event.action === 'close') {
    return;
  }

  // 「飲んだよ」アクションの場合は服薬完了をサーバーに送信
  if (event.action === 'taken') {
    const medicationManagementId = event.notification.data?.medication_management_id;
    if (medicationManagementId) {
      event.waitUntil(
        fetch('/web_push_actions', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            action: 'taken',
            medication_management_id: medicationManagementId
          })
        }).then(() => {
          console.log('服薬完了をサーバーに送信しました');
        }).catch(error => {
          console.error('服薬完了の送信に失敗しました:', error);
        })
      );
    }
    return;
  }

  // 開くべきURLを取得（通知データから、またはデフォルトでルート）
  const urlToOpen = event.notification.data?.url || '/';

  // 既存のタブを探すか、新しいタブを開く処理
  event.waitUntil(
    clients.matchAll({
      type: 'window',
      includeUncontrolled: true
    }).then(function(clientList) {
      // 既に開いているタブで該当URLがあるかチェック
      for (let client of clientList) {
        if (client.url.includes(urlToOpen) && 'focus' in client) {
          return client.focus(); // 既存タブにフォーカス
        }
      }

      // 既存タブがない場合は新しいタブを開く
      if (clients.openWindow) {
        return clients.openWindow(urlToOpen);
      }
    })
  );
});

/**
 * Service Worker のインストール処理
 * Service Workerが初回インストールされる際に実行される
 */
self.addEventListener('install', function(event) {
  console.log('Service Worker がインストールされました');
  // 新しいService Workerを即座に有効化
  self.skipWaiting();
});

/**
 * Service Worker の有効化処理
 * Service Workerがアクティブになった際に実行される
 */
self.addEventListener('activate', function(event) {
  console.log('Service Worker が有効化されました');
  // 全てのクライアント（タブ）を制御下に置く
  event.waitUntil(self.clients.claim());
});

/**
 * グローバルエラーハンドラー
 * キャッチされないエラーを処理
 */
self.addEventListener('error', function(event) {
  console.error('Service Worker エラー:', event.error);
});

/**
 * メッセージハンドラー
 * クライアントからのメッセージに応答
 */
self.addEventListener('message', function(event) {
  console.log('Service Worker がメッセージを受信:', event.data);

  // ポートが閉じられる前に応答を送信
  if (event.ports && event.ports.length > 0) {
    try {
      event.ports[0].postMessage({
        type: 'ack',
        message: 'Service Worker has received your message'
      });
    } catch (error) {
      console.error('Service Worker メッセージ応答エラー:', error);
    }
  }
});