class MedicationSchedulesController < ApplicationController
  before_action :get_medication_schedule, only: %i[edit update destroy]

  def new
    @medication_group = MedicationGroup.find(params[:medication_group_id])
    @medication_schedule = @medication_group.medication_schedules.build
  end

  def create
    @medication_group = MedicationGroup.find(params[:medication_group_id])

    # サーバー側でもセキュリティチェック
    if maximum_message = MedicationSchedule.check_medication_schedule_maximum(params[:medication_group_id])
      @medication_schedule = @medication_group.medication_schedules.build(medication_schedule_update_param)
      @medication_schedule.errors.add(:base, maximum_message)
      render turbo_stream: turbo_stream.update(
        "modal",
        template: "medication_schedules/new",
        locals: { medication_schedule: @medication_schedule }
      ), status: :unprocessable_entity
      return
    end

    if @medication_schedule = @medication_group.medication_schedules.create(medication_schedule_update_param)
      # 最新のスケジュール一覧を取得してボタン状態を更新
      @medication_schedules = @medication_group.medication_schedules
      render turbo_stream: [
        turbo_stream.append(
        "medication_schedules",
        partial: "medication_schedules/medication_schedule",
        locals: { medication_schedule: @medication_schedule }),
        turbo_stream.replace(
        "schedule_add_button",
        partial: "medication_schedules/add_button",
        locals: { medication_group: @medication_group, medication_schedules: @medication_schedules }),
        turbo_flash("success", "スケジュールを作成しました")
      ]
    else
      render turbo_stream: turbo_stream.update(
        "modal",
        template: "medication_schedules/new",
        locals: { medication_schedule: @medication_schedule }
      ), status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @medication_schedule.update(medication_schedule_update_param)
      render turbo_stream: [
        turbo_stream.replace(
          @medication_schedule,
          partial: "medication_schedules/medication_schedule",
          locals: { medication_schedule: @medication_schedule }),
        turbo_flash("success", "スケジュールを更新しました")
      ]
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @medication_schedule.destroy
      # 削除後の最新のスケジュール一覧を取得してボタン状態を更新
      @medication_group = @medication_schedule.medication_group
      @medication_schedules = @medication_group.medication_schedules
      render turbo_stream: [
        turbo_stream.remove("medication_schedule_#{@medication_schedule.id}"),
        turbo_stream.replace(
        "schedule_add_button",
        partial: "medication_schedules/add_button",
        locals: { medication_group: @medication_group, medication_schedules: @medication_schedules }),
        turbo_flash("success", "スケジュールを削除しました")
      ]
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def get_medication_schedule
    @medication_schedule = MedicationSchedule.find(params[:id])
  end

  def medication_schedule_update_param
    params.require(:medication_schedule).permit(:title, :medication_time, :reminder_count, :reminder_interval, :family_notification_delay)
  end
end
