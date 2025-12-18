package com.yourcompany.okusuri

import android.app.Activity
import android.webkit.JavascriptInterface
import android.webkit.WebView
import androidx.appcompat.app.AlertDialog
import org.json.JSONObject

/**
 * WebビューとAndroidネイティブコード間のJavaScriptブリッジ
 */
class WebAppInterface(
    private val activity: Activity,
    private val webView: WebView
) {
    /**
     * ページロード完了時の処理
     */
    @JavascriptInterface
    fun onPageLoaded(title: String, url: String) {
        activity.runOnUiThread {
            activity.title = title
            println("Page loaded - Title: $title, URL: $url")
        }
    }

    /**
     * タイトル設定
     */
    @JavascriptInterface
    fun setTitle(data: String) {
        try {
            val json = JSONObject(data)
            val title = json.getString("title")

            activity.runOnUiThread {
                activity.title = title
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    /**
     * アラート表示
     */
    @JavascriptInterface
    fun showAlert(data: String) {
        try {
            val json = JSONObject(data)
            val title = json.optString("title", "通知")
            val message = json.optString("message", "")

            activity.runOnUiThread {
                AlertDialog.Builder(activity)
                    .setTitle(title)
                    .setMessage(message)
                    .setPositiveButton("OK", null)
                    .show()
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    /**
     * 確認ダイアログ表示
     */
    @JavascriptInterface
    fun showConfirm(data: String) {
        try {
            val json = JSONObject(data)
            val title = json.optString("title", "確認")
            val message = json.optString("message", "")

            activity.runOnUiThread {
                AlertDialog.Builder(activity)
                    .setTitle(title)
                    .setMessage(message)
                    .setPositiveButton("OK") { _, _ ->
                        webView.evaluateJavascript("window.confirmResult = true;", null)
                    }
                    .setNegativeButton("キャンセル") { _, _ ->
                        webView.evaluateJavascript("window.confirmResult = false;", null)
                    }
                    .show()
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    /**
     * プッシュ通知トークンの処理
     */
    @JavascriptInterface
    fun onPushNotificationToken(token: String) {
        println("Received push notification token: $token")

        // デバイストークンをサーバーに送信する処理をここに実装
        // 例: Retrofit を使ってAPIエンドポイントにPOSTリクエスト
    }

    /**
     * デバイストークンをWebビューに送信
     */
    fun sendDeviceToken(token: String) {
        activity.runOnUiThread {
            webView.evaluateJavascript("window.nativeDeviceToken = '$token';", null)
        }
    }

    /**
     * ネイティブイベントをWebに通知
     */
    fun notifyNativeEvent(eventName: String, data: JSONObject) {
        activity.runOnUiThread {
            val script = """
                window.dispatchEvent(new CustomEvent('$eventName', {
                    detail: $data
                }));
            """.trimIndent()

            webView.evaluateJavascript(script, null)
        }
    }
}
