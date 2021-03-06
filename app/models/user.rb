class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :books
  has_many :favorites, dependent: :destroy
  has_many :book_comments, dependent: :destroy
  has_many :favorites_books,through: :favorites, source: :post

# フォローした・されたの関係
  has_many :relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :reverse_of_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy

# 一覧画面表示用
  has_many :followings, through: :relationships, source: :followed
  has_many :followers, through: :reverse_of_relationships, source: :follower

  # グループ機能
  has_many :group_users
  has_many :groups, through: :group_users

  # チャット機能
  has_many :rooms, through: :user_rooms
  has_many :user_rooms, dependent: :destroy
  has_many :chats, dependent: :destroy



  has_one_attached :profile_image

  validates :name, length: { in: 2..20}, uniqueness: true
  validates :introduction, length: { maximum: 50 }


  def get_profile_image
    (profile_image.attached?) ? profile_image : 'no_image.jpg'
  end

  # followした時
  def follow(user_id)
    relationships.create(followed_id: user_id)
  end

# フォローを外す
  def unfollow(user_id)
    relationships.find_by(followed_id: user_id).destroy
  end

# フォローをしているかの判定
  def following?(user)
    followings.include?(user)
  end

end
