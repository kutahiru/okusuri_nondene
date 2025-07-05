class MedicationGroupsController < ApplicationController
  before_action :set_medication_group_detail, only: %i[show]
  before_action :set_medication_group, only: %i[edit update destroy]

  def index
    @medication_groups = current_user.get_user_groups
  end

  def show
  end

  def new
    @medication_group = MedicationGroup.new
  end

  def create
    begin
      @medication_group = MedicationGroup.create_group_with_user!(medication_group_update_param, current_user.id)

      flash[:success] = "グループを作成しました"
      redirect_to medication_group_path(@medication_group)
    rescue ActiveRecord::RecordInvalid => e
      if e.record.is_a?(MedicationGroup)
        # MedicationGroupのバリデーションエラーの場合、元のエラーを保持
        @medication_group = e.record
      else
        # MedicationGroupUserのバリデーションエラーの場合、新しいインスタンスに:baseエラーを追加
        @medication_group = MedicationGroup.new(medication_group_update_param)
        error_message = extract_user_friendly_message(e.message)
        @medication_group.errors.add(:base, error_message)
      end

      render turbo_stream: turbo_stream.update(
        "modal",
        template: "medication_groups/new",
        locals: { medication_group: @medication_group }
      ), status: :unprocessable_entity
    end
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
      render turbo_stream: turbo_stream.update(
        "modal",
        template: "medication_groups/edit",
        locals: { medication_group: @medication_group }
      ), status: :unprocessable_entity
    end
  end

  def destroy
    if @medication_group.destroy
      render turbo_stream: [
        turbo_stream.remove("medication_group_#{@medication_group.id}"),
        turbo_flash("success", "グループを削除しました")
      ]
    else
      error_message = @medication_group.errors.any? ?
                     @medication_group.errors.full_messages.join(", ") :
                     "削除に失敗しました"
      render turbo_stream: turbo_flash("error", error_message)
    end
  end

  private

  def set_medication_group_detail
    @medication_group = current_user.medication_groups.find(params[:id])
    @medication_group_users = @medication_group.medication_group_users.includes(:user).order("medication_group_users.user_type DESC")
    @medication_schedules = @medication_group.medication_schedules # グループに紐づくスケジュールを取得
    @reward_condition = @medication_group.reward_condition # グループに紐づくご褒美管理を取得
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to medication_groups_path, alert: "アクセス権限がないか、グループが存在しません。" }
      format.turbo_stream { 
        render turbo_stream: [
          turbo_flash("alert", "アクセス権限がないか、グループが存在しません。")
        ]
      }
    end
  end

  def set_medication_group
    @medication_group = current_user.medication_groups.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to medication_groups_path, alert: "アクセス権限がないか、グループが存在しません。"
  end

  def medication_group_update_param
    params.require(:medication_group).permit(:group_name)
  end

  def extract_user_friendly_message(error_message)
    error_message.gsub(/^バリデーションに失敗しました:\s*/, "")
  end
end
