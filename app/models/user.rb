class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable,
         :lockable

  validates :email, email: true, presence: true, uniqueness: { case_sensitive: false }
  validates :username, presence: true,
                       uniqueness: { case_sensitive: false },
                       format: { with: /\A[a-z0-9_]+\z/i },
                       length: { minimum: 3, maximum: 30 }
  # `dependent: :destroy` (not :delete_all) is required so each Image runs its
  # Active Storage purge callback -- a DB-level cascade alone would orphan the
  # stored blobs. Destroying inherently loads the association, so exempt it from
  # strict loading the way Recipe does for its tagging associations; an
  # association-level :strict_loading option overrides the owner's setting.
  has_many :recipes, dependent: :destroy, strict_loading: false

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
