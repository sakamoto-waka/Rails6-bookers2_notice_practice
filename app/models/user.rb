class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :books, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :book_comments, dependent: :destroy
  has_one_attached :profile_image

  # Relationshipの中のカラムを区別するために,
  # 実質２分割[relationships(中身はfollower_id)とreverse_of_relationships(中身はfollowed_id)]する
  # フォローした人(Follower)とのアソシエーション　→　'follower_id'によって、あっちと✗（の:followerと）結びついた
  has_many :relationships, foreign_key: 'follower_id', dependent: :destroy
  # フォローされた人(Followed)とのアソシエーション　→　'followed_id'によって、あっちと✗（の:followedと）結びついた
  has_many :reverse_of_relationships, class_name: 'Relationship', foreign_key: 'followed_id', dependent: :destroy

  # 一覧画面で使用
  has_many :followings, through: :relationships, source: :followed
  has_many :followers, through: :reverse_of_relationships, source: :follower


  validates :name, length: { minimum: 2, maximum: 20 }, uniqueness: true
  validates :introduction, length: { maximum: 50 }



  def get_profile_image
    (profile_image.attached?) ? profile_image : 'no_image.jpg'
  end

  def follow(user_id)
    relationships.create(followed_id: user_id)
  end
  def unfollow(user_id)
    relationships.find_by(followed_id: user_id).destroy
  end
  def following?(user)
    followings.include?(user)
  end
  def follower?(user)
    followers.include?(user)
  end

  def self.looks(search, word)

    if search == 'perfect_match'
      User.where(name: word)
    elsif search == 'forward_match'
      User.where('name LIKE ?', "#{word}%")
    elsif search == 'backward_match'
      User.where('name LIKE ?', "%#{word}")
    else
      User.where('name LIKE ?', "%#{word}%")
    end
  end
end
