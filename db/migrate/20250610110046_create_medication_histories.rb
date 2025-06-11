class CreateMedicationHistories < ActiveRecord::Migration[7.2]
  def change
    create_table :medication_histories do |t|
      t.references :user, null: false, foreign_key: true
      t.date :medication_date, null: false
      t.string :drug_name, comment: "薬剤名"
      t.datetime :completed_at, comment: "服薬済み時刻"

      t.timestamps
    end

    execute "COMMENT ON TABLE medication_histories IS '服薬履歴 薬剤名ありの履歴確認時に使用'"
  end
end
