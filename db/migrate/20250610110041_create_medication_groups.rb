class CreateMedicationGroups < ActiveRecord::Migration[7.2]
  def change
    create_table :medication_groups do |t|
      t.string :group_name, null: false
      t.timestamps
    end

    # テーブルコメント
    execute "COMMENT ON TABLE medication_groups IS '服薬グループ'"
  end
end
