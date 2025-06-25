class MedicationSchedulesController < ApplicationController
  before_action :get_medication_schedule, only: %i[edit update destroy]
  def new
    @medication_group = MedicationGroup.find(params[:medication_group_id])
    @medication_schedule = @medication_group.medication_schedules.build
  end

  def create
    @medication_group = MedicationGroup.find(params[:medication_group_id])
    @medication_schedule = @medication_group.medication_schedules.create!(medication_schedule_update_param)

    render turbo_stream: turbo_stream.append(
      "medication_schedules",
      partial: "medication_schedules/medication_schedule",
      locals: { medication_schedule: @medication_schedule }
    )
  end

  def edit
  end

  def update
    if @medication_schedule.update(medication_schedule_update_param)
      render turbo_stream: turbo_stream.replace(
        @medication_schedule,
        partial: "medication_schedules/medication_schedule",
        locals: { medication_schedule: @medication_schedule }
      )
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @medication_schedule.destroy
      render turbo_stream: turbo_stream.remove("medication_schedule_#{@medication_schedule.id}")
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
