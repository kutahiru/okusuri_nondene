class CreateMedicationHistories < ActiveRecord::Migration[7.2]
  def change
    create_table :medication_histories, comment: "服薬履歴" do |t|
      t.references :user, null: false, foreign_key: true
      t.date :medication_date, null: false
      t.string :drug_name, comment: "薬剤名"
      t.datetime :completed_at, comment: "服薬済み時刻"

      t.timestamps
    end
  end
end
