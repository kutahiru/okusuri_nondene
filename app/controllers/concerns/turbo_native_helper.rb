# frozen_string_literal: true

module TurboNativeHelper
  extend ActiveSupport::Concern

  included do
    helper_method :turbo_native_app?, :ios_app?, :android_app? if respond_to?(:helper_method)
  end

  # Turbo Nativeアプリからのリクエストかどうかを判定
  def turbo_native_app?
    request.user_agent.to_s.match?(/Turbo Native/)
  end

  # iOSアプリからのリクエストかどうかを判定
  def ios_app?
    turbo_native_app? && request.user_agent.to_s.match?(/iOS/)
  end

  # Androidアプリからのリクエストかどうかを判定
  def android_app?
    turbo_native_app? && request.user_agent.to_s.match?(/Android/)
  end
end
