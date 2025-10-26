class WebPushActionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!

  # WebPush通知のアクションを処理
  def create
    action = params.dig(:web_push_action, :action)
    medication_management_id = params.dig(:web_push_action, :medication_management_id)

    if action == "taken" && medication_management_id.present?
      handle_medication_taken(medication_management_id)
      render json: { status: "success", message: "服薬完了を記録しました" }
    else
      render json: {
        status: "error",
        message: "無効なアクションです"
      }, status: :bad_request
    end
  rescue => e
    Rails.logger.error "WebPushアクション処理エラー: #{e.message}"
    render json: {
      status: "error",
      message: "処理中にエラーが発生しました"
    }, status: :internal_server_error
  end

  private

  # 服薬済に変更する（LINE Botコントローラーと同じ処理）
  def handle_medication_taken(medication_management_id)
    MedicationManagement.update_is_taken!(medication_management_id.to_i)
  end
end
