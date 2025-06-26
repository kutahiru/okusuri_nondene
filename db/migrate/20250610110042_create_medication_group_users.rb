class CreateMedicationGroupUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :medication_group_users, comment: "服薬グループユーザー" do |t|
      t.references :medication_group, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :user_type, null: false, comment: "ユーザー区分 medication_taker:服薬者 family_watcher:見守り家族"

      t.timestamps
    end
  end
end
