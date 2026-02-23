class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  validates :email, email: true, presence: true, uniqueness: true
  validates :username, presence: true,
                       uniqueness: { case_sensitive: false },
                       format: { with: /\A[a-z0-9_]+\z/i },
                       length: { minimum: 3, maximum: 30 }
  has_many :recipes

  def admin?
    admin
  end

  def approved?
    admin? || self[:approved]
  end

  def active_for_authentication?
    super && approved?
  end

  def inactive_message
    approved? ? super : :pending_approval
  end
end
