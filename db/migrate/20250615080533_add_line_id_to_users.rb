class AddLineIdToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :line_user_id, :text
  end
end
