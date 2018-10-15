class User < ApplicationRecord
  has_secure_password

  has_many :sessions, dependent: :destroy
  has_many :password_sets, dependent: :destroy

  validates :email, presence: true, email: true, uniqueness: true
  validates :password, length: { min: 6, maximum: 36 }
  validates :password_confirmation, presence: true
end
