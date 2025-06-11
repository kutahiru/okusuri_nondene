class CreateScheduleDrugs < ActiveRecord::Migration[7.2]
  def change
    create_table :schedule_drugs do |t|
      t.references :medication_schedule, null: false, foreign_key: true
      t.string :drug_name, null: false, comment: "薬剤名"

      t.timestamps
    end

    execute "COMMENT ON TABLE schedule_drugs IS '服薬薬剤'"
  end
end
