class RewardConditionsController < ApplicationController
  before_action :set_reward_condition, only: %i[edit update destroy]
  before_action :set_medication_group, only: %i[new create]
  def new
    @reward_condition = @medication_group.build_reward_condition(condition_type: "weekly", target_weekday: "sunday", target_value: 10)
  end

  def create
    @reward_condition = @medication_group.build_reward_condition(reward_condition_update_param)

    if @reward_condition.save
      render turbo_stream: [
        turbo_stream.update(
        "reward_condition",
        partial: "reward_conditions/reward_condition",
        locals: { reward_condition: @reward_condition }),
        turbo_flash("success", "ご褒美設定を作成しました")
      ]
    else
      render turbo_stream: turbo_stream.update(
        "modal",
        template: "reward_conditions/new",
        locals: { reward_condition: @reward_condition }
      ), status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @reward_condition.update(reward_condition_update_param)
      render turbo_stream: [
        turbo_stream.replace(
          @reward_condition,
          partial: "reward_conditions/reward_condition",
          locals: { reward_condition: @reward_condition }),
        turbo_flash("success", "ご褒美設定を更新しました")
      ]
    else
      render turbo_stream: turbo_stream.update(
        "modal",
        template: "reward_conditions/edit",
        locals: { reward_condition: @reward_condition }
      ), status: :unprocessable_entity
    end
  end

  def destroy
    if @reward_condition.destroy
      render turbo_stream: [
        turbo_stream.update("reward_condition",
        partial: "reward_conditions/reward_condition_empty",
        locals: { medication_group: @medication_group }),
        turbo_flash("success", "ご褒美設定を削除しました")
      ]
    else
      error_message = @reward_condition.errors.any? ?
                     @reward_condition.errors.full_messages.join(", ") :
                     "削除に失敗しました"
      render turbo_stream: turbo_flash("error", error_message)
    end
  end

  private

  def set_reward_condition
    @reward_condition = current_user.reward_conditions.find(params[:id])
    @medication_group = @reward_condition.medication_group
  end

  def set_medication_group
    @medication_group = current_user.medication_groups.find(params[:medication_group_id])
  end

  def reward_condition_update_param
    params.require(:reward_condition).permit(:reward_name, :condition_type, :target_weekday, :target_value)
  end
end
