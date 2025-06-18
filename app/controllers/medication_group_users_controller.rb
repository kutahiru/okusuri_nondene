class MedicationGroupUsersController < ApplicationController
  def new
    @medication_group_users = MedicationGroupUser.new
  end
end
