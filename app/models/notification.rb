class Notification < ApplicationRecord
  # デフォルトで最新順にしてる　Notification.firstで最新の通知を取得
  default_scope -> { order(created_at: :desc) }
  belongs_to :book, optional: true #nilを許可する、これがないとbelong_toでnilはだめになる
  belongs_to :book_comment, optional: true
  
  belongs_to :visitor, class_name: 'User', foreign_key: 'visitor_id', optional: true
  belongs_to :visited, class_name: 'User', foreign_key: 'visited_id', optional: true
end
