class Bootstrap < ActiveRecord::Migration[7.0]
  def change
    create_table 'users', force: :cascade do |t|
      t.string 'address', null: false
      t.string 'nickname'
      t.string 'gender'
      t.string 'avatar'

      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
      t.datetime 'deleted_at'
    end

    add_index 'users', 'address', unique: true
    add_index 'users', 'nickname', unique: true

    create_table 'message_to_halls', force: :cascade do |t|
      # { message: '', from: {...} }
      t.string 'message', null: false

      t.datetime 'created_at', null: false
    end

    create_table 'chat_requests', force: :cascade do |t|
      t.string 'from_address', null: false
      t.string 'to_address', null: false
      t.boolean 'accepted'
      t.boolean 'canceled'

      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
    end

    create_table 'chats', force: :cascade do |t|
      t.string 'from_address', null: false
      t.string 'to_address', null: false
      t.string 'end_by'
      t.datetime 'end_at'
      t.integer 'from_response' # 0 - good, 1 - normal, 2 - bad
      t.string 'from_response_reason'
      t.integer 'to_response' # 0 - good, 1 - normal, 2 - bad
      t.string 'to_response_reason'

      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
    end

    create_table 'message_to_users', force: :cascade do |t|
      t.integer 'chat_id', null: false
      t.string 'message', null: false
      t.string 'from', null: false

      t.datetime 'created_at', null: false
    end
  end
end
