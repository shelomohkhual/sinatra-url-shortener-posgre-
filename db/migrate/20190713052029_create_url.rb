class CreateUrl < ActiveRecord::Migration[5.2]
  def change
    create_table :urls do |t|
      t.integer  :user_id
      t.string  :user_name
      t.text :ori_url
      t.text :short_url
      t.integer :freq
      t.timestamps
    end
  end
end
