class CreateMedicationGroups < ActiveRecord::Migration[7.2]
  def change
    create_table :medication_groups, comment: "服薬グループ" do |t|
      t.string :group_name, null: false
      t.timestamps
    end
  end
end
