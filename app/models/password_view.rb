class PasswordView < ApplicationRecord
  self.per_page = 25

  belongs_to :password_set
  belongs_to :viewer, class_name: 'User', required: false

  enum status: {
    decrypted: 'decrypted',
    viewed: 'viewed'
  }

  validates :status, inclusion: { in: PasswordView.statuses.values }
end
