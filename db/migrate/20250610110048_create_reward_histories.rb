class CreateRewardHistories < ActiveRecord::Migration[7.2]
  def change
    create_table :reward_histories do |t|
      t.references :medication_group, null: false, foreign_key: true
      t.string :reward_name, null: false, comment: "ご褒美名"
      t.date :reward_date, null: false, comment: "ご褒美獲得日"
      t.references :medication_managements, foreign_key: true,
                   comment: "ご褒美獲得時の最終服薬 次回のカウント開始に利用"

      t.timestamps
    end

    execute "COMMENT ON TABLE reward_histories IS 'ご褒美'"
  end
end
