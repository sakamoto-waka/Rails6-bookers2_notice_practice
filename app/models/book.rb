class Book < ApplicationRecord
  belongs_to :user
  has_many :favorites, dependent: :destroy
  has_many :book_comments, dependent: :destroy

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
end