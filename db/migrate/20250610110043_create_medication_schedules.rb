class CreateMedicationSchedules < ActiveRecord::Migration[7.2]
  def change
    create_table :medication_schedules do |t|
      t.references :medication_group, null: false, foreign_key: true
      t.time :medication_time, null: false, comment: "服薬時刻"
      t.integer :reminder_count, default: 0
      t.integer :reminder_interval, comment: "リマインド間隔（分）"
      t.integer :family_notification_delay, comment: "家族通知待機時間（分）"

      t.timestamps
    end

    execute "COMMENT ON TABLE medication_schedules IS '服薬スケジュール'"
  end
end
