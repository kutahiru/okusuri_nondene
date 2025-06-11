class MedicationGroupsController < ApplicationController
  def index
    @medication_groups = current_user.get_user_groups
  end

  def edit
  end
end
