class Password < ApplicationRecord
  belongs_to :password_set

  validates :encrypted_password, presence: true
end
