package com.yourcompany.okusuri

import android.os.Bundle
import android.webkit.WebView
import androidx.appcompat.app.AlertDialog
import androidx.fragment.app.Fragment
import dev.hotwire.turbo.config.TurboPathConfiguration
import dev.hotwire.turbo.session.TurboSessionNavHostFragment
import kotlin.reflect.KClass

class TurboSessionNavHostFragment : TurboSessionNavHostFragment() {
    companion object {
        fun newInstance(startLocation: String): TurboSessionNavHostFragment {
            return TurboSessionNavHostFragment().apply {
                arguments = Bundle().apply {
                    putString("startLocation", startLocation)
                }
            }
        }
    }

    override val sessionName = "main"

    override val startLocation: String
        get() = arguments?.getString("startLocation") ?: "http://10.0.2.2:3000/"

    override val registeredActivities: List<KClass<out androidx.appcompat.app.AppCompatActivity>>
        get() = listOf()

    override val registeredFragments: List<KClass<out Fragment>>
        get() = listOf(
            WebFragment::class
        )

    override val pathConfigurationLocation: TurboPathConfiguration.Location
        get() = TurboPathConfiguration.Location(
            remoteFileUrl = "$startLocation/turbo_native/configuration"
        )

    override fun onSessionCreated() {
        super.onSessionCreated()

        // WebViewの設定
        session.webView.settings.apply {
            javaScriptEnabled = true
            domStorageEnabled = true
        }

        // JavaScriptインターフェースの追加
        session.webView.addJavascriptInterface(
            WebAppInterface(requireActivity(), session.webView),
            "NativeApp"
        )
    }

    override fun onFormSubmissionStarted(location: String) {
        // フォーム送信開始時の処理（ローディング表示など）
    }

    override fun onFormSubmissionFinished(location: String) {
        // フォーム送信完了時の処理
    }

    override fun onVisitErrorReceived(location: String, errorCode: Int) {
        // エラー発生時の処理
        AlertDialog.Builder(requireContext())
            .setTitle("エラー")
            .setMessage("ページの読み込みに失敗しました。\nエラーコード: $errorCode")
            .setPositiveButton("再試行") { _, _ ->
                session.visit(location)
            }
            .setNegativeButton("閉じる", null)
            .show()
    }
}

class WebFragment : dev.hotwire.turbo.fragments.TurboWebFragment()
