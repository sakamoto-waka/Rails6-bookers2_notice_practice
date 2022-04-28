class Book < ApplicationRecord
  belongs_to :user
  has_many :favorites, dependent: :destroy
  has_many :book_comments, dependent: :destroy
  # 通知用アソシエーション
  has_many :notifications, dependent: :destroy

  validates :title,presence:true
  validates :body,presence:true,length:{maximum:200}

  def favorited_by?(user)
    favorites.exists?(user_id: user.id)
  end

  def self.looks(search, word)
    if search == 'perfect_match'
      Book.where(title: word)
    elsif search == 'forward_match'
      Book.where('title LIKE ? OR body LIKE ?', "#{word}%", "#{word}%")
    elsif search == 'backward_match'
      Book.where('title LIKE ? OR body LIKE ?', "%#{word}", "%#{word}")
    else
      Book.where('title LIKE ? OR body LIKE ?', "%#{word}%", "%#{word}%")
    end
  end
  
  def create_notification_favorite!(current_user)
    # 既にいいねされてるかチェック
    temp = Notification.where(["visitor_id = ? and visited_id = ? and book_id = ? and action = ?", current_user.id, user_id, id, 'favorite'])
    # いいねされていない時のみ通知レコードを作成
    if temp.blank?
      notification = current_user.active_notifications.new(book_id: id,
                                                           visited_id: user_id,
                                                           action: 'favorite')
      # 自分の投稿に対する自分のいいねの場合は通知済みとする
      if notification.visitor_id == notification.visited_id
        notification.checked = true
      end
      notification.save if notification.valid?
    end
  end
  
  def create_notification_book_comment!(current_user, book_comment_id)
    # (全体の処理→)自分以外のコメントしている人を全て取得し、全員に通知を送る
    temp_ids = BookComment.select(:user_id).where(book_id: id).where.not(user_id: current_user.id).distinct
    temp_ids.each do |temp_id|
      # ここの下に↓このメソッド作成してる
      save_notification_book_comment!(current_user, book_comment_id, temp_id[('user_id')])
    end
    # まだ誰もコメントしていない場合は、投稿者に通知を送る
    save_notification_book_comment!(current_user, book_comment_id, user_id) if temp_ids.blank?
  end
  
  def save_notification_book_comment!(current_user, book_comment_id, visited_id)
    # コメントは複数回することが考えられる→（通知存在確認処理はしない）１つの投稿に複数回通知する
    notification = current_user.active_notifications.new(book_id: id,
                                                         book_comment_id: book_comment_id,
                                                         visited_id: visited_id,
                                                         action: 'book_comment')
    # 自分の投稿に対する自分のコメントは通知済みにする
    if notification.visitor_id == notification.visited_id
      notification.checked = true
    end
    notification.save if notification.valid?
  end
  
end