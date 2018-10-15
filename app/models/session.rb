class Session < ApplicationRecord
  belongs_to :user

  enum device: {
    web: 'web',
    ios: 'ios',
    android: 'android'
  }

  validates :access_token, presence: true, uniqueness: true
  validates :access_token_expired_at, presence: true
  validates :refresh_token, presence: true, uniqueness: true
  validates :refresh_token_expired_at, presence: true
  validates :device, inclusion: { in: Session.devices.values }

  scope :active, -> { where('access_token_expired_at > ?', Time.current) }
  scope :refreshable, -> { where('refresh_token_expired_at > ?', Time.current) }
end
