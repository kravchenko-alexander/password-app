require 'faker'

FactoryBot.define do
  factory :session, class: Session do
    device { 'web' }
    push_token { SecureRandom.hex }
    access_token { SecureRandom.hex }
    access_token_expired_at { Time.current + 1.day }
    refresh_token { SecureRandom.hex }
    refresh_token_expired_at { Time.current + 1.year }
    user
  end

  trait :non_active do
    access_token_expired_at { Time.current - 1.day }
  end

  trait :non_refreshable do
    refresh_token_expired_at { Time.current + 1.year }
  end
end
