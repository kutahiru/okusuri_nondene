class AddOriginalScheduleTitleToMedicationManagements < ActiveRecord::Migration[7.2]
  def change
    add_column :medication_managements, :original_schedule_title, :string
  end
end
