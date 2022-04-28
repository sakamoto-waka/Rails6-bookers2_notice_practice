class CreateNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :notifications do |t|
      t.integer :visitor_id, null:false
      t.integer :visited_id, null:false
      t.integer :book_id
      t.integer :book_comment_id
      t.string :action, default: '', null: false
      # 通知を確認したか
      t.boolean :checked, default: false, null: false

      t.timestamps
    end
    
    add_index :notifications, :visitor_id
    add_index :notifications, :visited_id
    add_index :notifications, :book_id
    add_index :notifications, :book_comment_id
  end
end
