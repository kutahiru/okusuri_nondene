class CreateScheduleDrugs < ActiveRecord::Migration[7.2]
  def change
    create_table :schedule_drugs, comment: "服薬薬剤" do |t|
      t.references :medication_schedule, null: false, foreign_key: true
      t.string :drug_name, null: false, comment: "薬剤名"

      t.timestamps
    end
  end
end
