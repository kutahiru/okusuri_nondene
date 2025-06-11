class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :user_name, null: false, comment: "名前"
      t.string :provider, null: false
      t.string :uid, null: false
      t.boolean :description_read, default: false, null: false, comment: "アプリ説明読了フラグ"

      t.timestamps

      t.index [ :provider, :uid ], unique: true, name: "index_users_on_provider_and_uid"
    end
  end
end
