package com.yourcompany.okusuri

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import dev.hotwire.turbo.nav.TurboNavGraphDestination

// RailsサーバーのURL
private const val BASE_URL = "http://10.0.2.2:3000" // エミュレーター用
// 実機の場合は以下を使用:
// private const val BASE_URL = "http://YOUR_IP:3000"

@TurboNavGraphDestination(uri = "turbo://fragment/web")
class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // ディープリンクの処理
        handleIntent()
    }

    private fun handleIntent() {
        val url = intent.data?.toString() ?: "$BASE_URL/"

        // Turbo セッションの開始
        if (savedInstanceState == null) {
            supportFragmentManager.beginTransaction()
                .replace(R.id.nav_host_fragment, TurboSessionNavHostFragment.newInstance(url))
                .commit()
        }
    }

    override fun onNewIntent(intent: android.content.Intent?) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntent()
    }
}
