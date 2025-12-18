package com.yourcompany.okusuri

import android.app.Application
import dev.hotwire.turbo.config.Turbo
import dev.hotwire.turbo.session.TurboSessionNavHostFragment

class TurboApplication : Application() {
    override fun onCreate() {
        super.onCreate()

        // Turboの初期設定
        Turbo.config.apply {
            // デバッグモード（本番では false に設定）
            debugLoggingEnabled = true

            // User-Agent の設定
            userAgent = "Turbo Native Android"

            // Path Configurationの設定
            pathConfigurationLocation = PathConfiguration.Location(
                assetFilePath = "json/configuration.json"
            )
        }
    }
}
