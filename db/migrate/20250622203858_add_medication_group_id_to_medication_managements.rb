class AddMedicationGroupIdToMedicationManagements < ActiveRecord::Migration[7.2]
  def change
    add_reference :medication_managements, :medication_group, null: true, foreign_key: true, type: :bigint

    # 2. 既存データの medication_group_id を更新
    say_with_time "Updating existing medication_managements with medication_group_id" do
      execute <<-SQL
        UPDATE medication_managements#{' '}
        SET medication_group_id = medication_schedules.medication_group_id
        FROM medication_schedules#{' '}
        WHERE medication_managements.medication_schedule_id = medication_schedules.id
      SQL
    end

    # 3. 更新できなかったレコードがないか確認
    null_count = execute("SELECT COUNT(*) FROM medication_managements WHERE medication_group_id IS NULL").first['count'].to_i

    if null_count > 0
      raise "#{null_count} records could not be updated with medication_group_id. Please check data integrity."
    end

    # 4. NOT NULL制約を追加
    change_column_null :medication_managements, :medication_group_id, false
  end
end
