# frozen_string_literal: true

class TurboNativeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:configuration]

  # Path Configuration JSON
  # ネイティブアプリがどのURLをどのように扱うかを定義
  def configuration
    render json: {
      settings: {
        # ネイティブアプリのバージョン管理
        minimum_version: "1.0.0"
      },
      rules: [
        # ホーム画面（トップページ）
        {
          patterns: ["/", "/home"],
          properties: {
            context: "default",
            pull_to_refresh_enabled: true
          }
        },
        # お薬グループ一覧（メイン画面）
        {
          patterns: ["/medication_groups"],
          properties: {
            context: "default",
            pull_to_refresh_enabled: true
          }
        },
        # お薬グループ詳細・編集
        {
          patterns: [
            "/medication_groups/new",
            "/medication_groups/*/edit",
            "/medication_groups/\\d+"
          ],
          properties: {
            context: "modal",
            presentation: "modal"
          }
        },
        # お薬スケジュール管理
        {
          patterns: [
            "/medication_schedules/new",
            "/medication_schedules/*/edit"
          ],
          properties: {
            context: "modal",
            presentation: "modal"
          }
        },
        # お薬管理履歴
        {
          patterns: ["/medication_managements"],
          properties: {
            context: "default",
            pull_to_refresh_enabled: true
          }
        },
        # マイページ
        {
          patterns: ["/mypage"],
          properties: {
            context: "default",
            pull_to_refresh_enabled: false
          }
        },
        # マイページ編集
        {
          patterns: ["/mypage/edit"],
          properties: {
            context: "modal",
            presentation: "modal"
          }
        },
        # 招待URL
        {
          patterns: ["/invite/.*"],
          properties: {
            context: "modal",
            presentation: "modal"
          }
        },
        # グループメンバー管理
        {
          patterns: [
            "/medication_group_users/new",
            "/medication_group_users/edit_multiple"
          ],
          properties: {
            context: "modal",
            presentation: "modal"
          }
        },
        # リワード設定
        {
          patterns: [
            "/reward_conditions/new",
            "/reward_conditions/*/edit"
          ],
          properties: {
            context: "modal",
            presentation: "modal"
          }
        },
        # 認証関連
        {
          patterns: [
            "/users/sign_in",
            "/users/sign_out",
            "/users/auth/line",
            "/users/auth/line/callback"
          ],
          properties: {
            context: "modal",
            presentation: "modal"
          }
        },
        # 外部リンク（ブラウザで開く）
        {
          patterns: [
            "https://.*",
            "http://.*"
          ],
          properties: {
            presentation: "external"
          }
        }
      ]
    }
  end
end
