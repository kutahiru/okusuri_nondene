class User < ApplicationRecord
  validates :user_name, presence: true, length: { maximum: 255 }
  validates :provider, presence: true
  validates :uid, presence: true
  validates :provider, uniqueness: { scope: :uid }

  has_many :medication_group_users, dependent: :destroy
  has_many :medication_groups, through: :medication_group_users
  has_many :medication_histories, dependent: :destroy
  has_many :medication_group_invitations, dependent: :destroy

  enum description_read: { not_read: false, read: true }, _prefix: :description

  devise :rememberable,
         :omniauthable, omniauth_providers: [ :line ]


  def get_user_groups
    # 現在のユーザーが所属するグループとメンバー一覧を取得する
    medication_groups.includes(:users).order(id: :desc)
  end

  # lineから取得した情報を保存するためのカラムとの関連付け
  def self.from_line(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.user_name = auth.info.name
    end
  end
end
