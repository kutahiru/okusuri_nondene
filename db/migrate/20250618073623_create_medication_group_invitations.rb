class CreateMedicationGroupInvitations < ActiveRecord::Migration[7.2]
  def change
    create_table :medication_group_invitations, comment: "服薬グループ招待" do |t|
      t.references :medication_group, null: false, foreign_key: true, index: true
      t.references :user, null: false, foreign_key: true, index: true
      t.integer :max_uses, null: false, default: 1, comment: "最大使用数"
      t.integer :used_count, null: false, default: 0, comment: "使用回数"
      t.datetime :expires_at, comment: "有効期限"

      t.timestamps null: false
    end
  end
end
