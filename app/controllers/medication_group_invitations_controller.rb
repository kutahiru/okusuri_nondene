class MedicationGroupInvitationsController < ApplicationController
  before_action :get_medication_group_invitation_by_token, only: %i[ show accept ]

  # 招待リンクのページ
  def show
    @medication_group =  @medication_group_invitation.medication_group

    # ログイン後の戻り先URL
    session["user_return_to"] = request.fullpath unless user_signed_in?
  end

  def accept
    # 服薬グループユーザー作成
    MedicationGroupUser.create!(
      medication_group_id: @medication_group_invitation.medication_group_id,
      user_id: current_user.id,
      user_type: medication_group_invitation_params[:user_type].to_i
    )

    # 招待の使用回数を加算
    @medication_group_invitation.increment!(:used_count)

    redirect_to medication_group_path(@medication_group_invitation.medication_group)
  end

  # 招待リンク作成
  def create
    @medication_group = MedicationGroup.find(params[:medication_group_id])
    @medication_group_invitation = MedicationGroupInvitation.find_or_create_by(
      medication_group_id: @medication_group.id,
      user_id: current_user.id,
      max_uses: 3,
      expires_at: 3.days.from_now
    )

    # 期限付き、暗号化付きの招待用URLを生成
    if @medication_group_invitation.save
      @invitation_link = medication_group_invitation_token_url(
        @medication_group_invitation.signed_id(expires_in: 3.days, purpose: :medication_group_invitation)
      )

      render json: {
        success: true,
        invitation_link: @invitation_link
      }
    end
  end

  private

  def get_medication_group_invitation_by_token
    signed_id = params[:token]
    # 署名付きIDを使って招待レコードを取得
    @medication_group_invitation = MedicationGroupInvitation.find_signed(
      signed_id,
      purpose: :medication_group_invitation
    )
  end

  def medication_group_invitation_params
    params.permit(:user_type)
  end
end
