class Bootstrap < ActiveRecord::Migration[7.0]
  def change
    create_table 'users', force: :cascade do |t|
      t.string 'address', null: false
      t.string 'nickname'

      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
      t.datetime 'deleted_at'
    end

    add_index 'users', 'address', unique: true
    add_index 'users', 'nickname', unique: true
  end
end
