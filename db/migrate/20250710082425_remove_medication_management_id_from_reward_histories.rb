class RemoveMedicationManagementIdFromRewardHistories < ActiveRecord::Migration[7.2]
  def change
    remove_reference :reward_histories, :medication_management, foreign_key: true
  end
end
