class CreateRewardConditions < ActiveRecord::Migration[7.2]
  def change
    create_table :reward_conditions, comment: "ご褒美管理" do |t|
      t.references :medication_group, null: false, foreign_key: true
      t.string :reward_name, null: false, comment: "ご褒美名"
      t.integer :condition_type, null: false, comment: "条件タイプ 0:ご褒美なし 1:1週間 2:連続日数"
      t.string :target_weekday, comment: "曜日 条件タイプが1:1週間の場合に利用する"
      t.integer :target_value, comment: "連続目標値"

      t.timestamps
    end
  end
end
