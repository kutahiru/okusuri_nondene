class MedicationGroupsController < ApplicationController
  before_action :get_medication_group_detail, only: %i[show]
  before_action :get_medication_group, only: %i[edit update destroy]

  def index
    @medication_groups = current_user.get_user_groups
  end

  def new
    @medication_group = MedicationGroup.new
  end

  def create
    @medication_group = MedicationGroup.create!(medication_group_update_param)
    @medication_group.medication_group_users.create!(
      user_id: current_user.id,
      user_type: "medication_taker"
    )

    render turbo_stream: [
      turbo_stream.prepend(
      "medication_groups",
      partial: "medication_groups/medication_group",
      locals: { medication_group: @medication_group }
    ),
      turbo_flash("success", "グループを作成しました") ]
  end

  def show
  end

  def edit
  end

  def update
    if @medication_group.update(medication_group_update_param)
      render turbo_stream: [
        turbo_stream.replace(
          @medication_group,
          partial: "medication_groups/medication_group",
          locals: { medication_group: @medication_group }
        ),
        turbo_flash("success", "グループを更新しました")
      ]
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @medication_group.destroy
      render turbo_stream: [
        turbo_stream.remove("medication_group_#{@medication_group.id}"),
        turbo_flash("success", "グループを削除しました")
      ]
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def get_medication_group_detail
    @medication_group = current_user.medication_groups.find(params[:id])
    @medication_group_users = @medication_group.medication_group_users.includes(:user).order("medication_group_users.user_type DESC")
    @medication_schedules = @medication_group.medication_schedules # グループに紐づくスケジュールを取得
    @reward_condition = @medication_group.reward_condition # グループに紐づくご褒美管理を取得
  rescue ActiveRecord::RecordNotFound
    render turbo_stream: [
      turbo_flash("alert", "アクセス権限がないか、グループが存在しません。")
    ]
    # redirect_to medication_groups_path, alert: "アクセス権限がないか、グループが存在しません。"
  end

  def get_medication_group
    @medication_group = current_user.medication_groups.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to medication_groups_path, alert: "アクセス権限がないか、グループが存在しません。"
  end

  def medication_group_update_param
    params.require(:medication_group).permit(:group_name)
  end
end
