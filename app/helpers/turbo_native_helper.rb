# frozen_string_literal: true

module TurboNativeHelper
  # Turbo Nativeアプリ専用のコンテンツを表示するヘルパー
  def turbo_native_only(&block)
    return unless turbo_native_app?

    capture(&block)
  end

  # Web版専用のコンテンツを表示するヘルパー
  def web_only(&block)
    return if turbo_native_app?

    capture(&block)
  end

  # プラットフォーム固有のクラスを追加
  def platform_classes
    classes = []
    classes << "turbo-native" if turbo_native_app?
    classes << "ios" if ios_app?
    classes << "android" if android_app?
    classes.join(" ")
  end
end
