class MedicationGroupsController < ApplicationController
  before_action :get_medication_group, only: %i[show]

  def index
    @medication_groups = current_user.get_user_groups
  end

  def show
  end

  def edit
  end

  private

  def get_medication_group
    @medication_group = current_user.medication_groups.includes(:users).find(params[:id])
    @medication_schedules = @medication_group.medication_schedules # グループに紐づくスケジュールを取得
  rescue ActiveRecord::RecordNotFound
    redirect_to medication_groups_path, alert: "アクセス権限がないか、グループが存在しません。"
  end
end
