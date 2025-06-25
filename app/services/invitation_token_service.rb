class InvitationTokenService
  def initialize(medication_group_id, user_id)
    @medication_group_id = medication_group_id
    @user_id = user_id
  end

  # 期限付き、暗号化付きのトークンを生成
  def call
    @medication_group_invitation = MedicationGroupInvitation.find_or_create_active_invitation(@medication_group_id, @user_id)
    @medication_group_invitation.signed_id(expires_in: 3.days, purpose: :medication_group_invitation)
  end
end
