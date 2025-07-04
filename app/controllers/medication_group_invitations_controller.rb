class MedicationGroupInvitationsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[show]
  before_action :set_medication_group_invitation_by_token, only: %i[show accept]

  # 招待リンク作成
  def create
    invitation_token_service = InvitationTokenService.new(params[:medication_group_id], current_user.id)

    # 期限付き、暗号化付きの招待用URLを生成
    invitation_link = medication_group_invitation_token_url(invitation_token_service.call)

    # クリップボードにコピーするためjsonで連携
    render json: {
      success: true,
      invitation_link: invitation_link
    }
  end

  # 招待リンクのページ
  def show
    @medication_group =  @medication_group_invitation.medication_group

    # ログイン後の戻り先URL
    session["user_return_to"] = request.fullpath unless user_signed_in?
  end

  # 招待認証時の処理
  def accept
    # 既にグループに参加していたらメッセージ
    if MedicationGroupUser.exists?(medication_group_id: @medication_group_invitation.medication_group_id, user_id: current_user.id)
      render turbo_stream: [
        turbo_flash("information", "既にグループに参加しています。") ]
        return
    end

    @medication_group_invitation.accept_invitation!(
      current_user.id,
      medication_group_invitation_params[:user_type]
      )

    redirect_to medication_group_path(@medication_group_invitation.medication_group)
  end

  private

  # トークンを使って招待レコードを取得
  def set_medication_group_invitation_by_token
    @medication_group_invitation = MedicationGroupInvitation.find_by_token(params[:token])
  end

  def medication_group_invitation_params
    params.permit(:user_type)
  end
end
