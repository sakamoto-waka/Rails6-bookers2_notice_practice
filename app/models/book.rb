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
    temp = Notification.where(["visitor_id = ? and vistited_id = ? and book_id = ? and action = ?", current_user.id, user_id, id, 'favorite'])
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
  
end