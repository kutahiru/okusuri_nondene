class CreateMedicationManagements < ActiveRecord::Migration[7.2]
  def change
    create_table :medication_managements do |t|
      t.references :medication_schedule, null: false, foreign_key: true
      t.date :medication_date, null: false
      t.boolean :is_taken, default: false, null: false, comment: "0:未服薬 1:服薬済み"
      t.datetime :completed_at, comment: "服薬済み時刻"
      t.integer :reminder_sent_count, default: 0, null: false, comment: "リマインダー送信回数"

      t.timestamps
    end

    execute "COMMENT ON TABLE medication_managements IS '服薬管理'"
  end
end
