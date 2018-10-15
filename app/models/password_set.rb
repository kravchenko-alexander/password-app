class PasswordSet < ApplicationRecord
  belongs_to :user
  has_many :passwords, dependent: :destroy
  has_many :password_views, dependent: :destroy

  validates :access_token, presence: true, uniqueness: true

  scope :active, -> { where(decrypted: false) }
end
