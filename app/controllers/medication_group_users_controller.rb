class MedicationGroupUsersController < ApplicationController
  before_action :set_medication_group_user, only: [ :destroy ]

  def new
    @medication_group_users = MedicationGroupUser.new
  end

  def edit_multiple
    @medication_group_users = MedicationGroupUser.where(medication_group_id: params[:medication_group_id]).order(:id)
  end

  def update_multiple
    medication_group_id = params[:medication_group_id]

    params[:medication_group_users].each do |index, user_params|
      medication_group_user = MedicationGroupUser.find(user_params[:id])
      medication_group_user.update!(user_type: user_params[:user_type])
    end

    # 更新後のデータを取得
    @medication_group_users = MedicationGroupUser.where(medication_group_id: medication_group_id).includes(:user).order("medication_group_users.user_type")

    respond_to do |format|
      format.html { redirect_to medication_group_path(medication_group_id), notice: "メンバーのロールを更新しました。" }
      format.turbo_stream {
        render turbo_stream: turbo_stream.update(
          "medication_group_users",
          partial: "medication_group_users/medication_group_user",
          collection: @medication_group_users,
          as: :medication_group_user
        )
      }
    end
  rescue StandardError => e
    respond_to do |format|
      format.html { redirect_to edit_multiple_medication_group_medication_group_users_path(medication_group_id), alert: "更新に失敗しました: #{e.message}" }
      format.turbo_stream { render turbo_stream: turbo_stream.update("modal", partial: "shared/error", locals: { message: e.message }) }
    end
  end

  def destroy
    medication_group_id = @medication_group_user.medication_group_id
    @medication_group_user.destroy

    # 更新後のデータを取得
    @medication_group_users = MedicationGroupUser.where(medication_group_id: medication_group_id).includes(:user).order("medication_group_users.user_type")

    respond_to do |format|
      format.html { redirect_to medication_group_path(medication_group_id), notice: "メンバーを削除しました。" }
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.update(
            "medication_group_users",
            partial: "medication_group_users/medication_group_user",
            collection: @medication_group_users,
            as: :medication_group_user
          ),
          turbo_stream.update("modal", "")
        ]
      }
    end
  end

  private

  def set_medication_group_user
    @medication_group_user = MedicationGroupUser.find(params[:id])
  end
end
