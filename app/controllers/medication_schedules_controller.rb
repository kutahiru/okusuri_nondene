class MedicationSchedulesController < ApplicationController
  def edit
    @medication_schedule = MedicationSchedule.find(params[:id])
  end
end
