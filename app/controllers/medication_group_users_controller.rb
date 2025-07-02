class MedicationGroupUsersController < ApplicationController
  before_action :set_medication_group_user, only: %i[destroy]
  before_action :set_medication_group, only: %i[edit_multiple update_multiple]

  def new
    @medication_group_users = MedicationGroupUser.new
  end

  def edit_multiple
    @medication_group_users = @medication_group.medication_group_users.order(user_type: :desc)
  end

  def update_multiple
    selected_medication_group_user_id = medication_group_user_update_params[:selected_medication_group_user_id]

    # グループ内の服薬者を変更
    MedicationGroupUser.update_medication_taker_in_group!(@medication_group.id, selected_medication_group_user_id)

    # 更新後のユーザー一覧を取得
    @medication_group_users = @medication_group.medication_group_users.includes(:user).order("medication_group_users.user_type desc")

    render turbo_stream: [
      turbo_stream.update(
      "medication_group_users",
      partial: "medication_group_users/medication_group_user",
      collection: @medication_group_users,
      as: :medication_group_user),
    turbo_flash("success", "メンバーを更新しました")
    ]
  rescue StandardError => e
    render turbo_stream: turbo_flash("error", "更新に失敗しました: #{e.message}")
  end

  def destroy
    medication_group_id = @medication_group_user.medication_group_id

    if @medication_group_user.destroy
      # 更新後のデータを取得
      @medication_group_users = MedicationGroupUser.where(medication_group_id: medication_group_id).includes(:user).order("medication_group_users.user_type")

      render turbo_stream: [
        turbo_stream.update(
          "medication_group_users",
          partial: "medication_group_users/medication_group_user",
          collection: @medication_group_users,
          as: :medication_group_user
        ),
        turbo_stream.update("modal", ""),
        turbo_flash("success", "メンバーを削除しました")
      ]
    else
      error_message = @medication_group_user.errors.any? ?
                      @medication_group_user.errors.full_messages.join(", ") :
                      "削除に失敗しました"
      render turbo_stream: turbo_flash("error", error_message)
    end
  end

  private

  def set_medication_group
    @medication_group = current_user.medication_groups.find(params[:medication_group_id])
  end

  def set_medication_group_user
    @medication_group_user = current_user.medication_groups.find(params[:medication_group_id]).medication_group_users.find(params[:id])
  end

  def medication_group_user_update_params
    params.permit(:selected_medication_group_user_id)
  end
end
