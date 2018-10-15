require 'faker'

FactoryBot.define do
  factory :password_set, class: PasswordSet do
    access_token { SecureRandom.hex }
    user
  end

  trait :with_passwords do
    after(:create) do |password_set|
      3.times do
        create(:password, password_set: password_set)
      end
    end
  end

  trait :with_password do
    after(:create) do |password_set|
      create(:password, password_set: password_set)
    end
  end

  trait :with_views do
    after(:create) do |password_set|
      3.times do
        create(:password_view, password_set: password_set)
      end
    end
  end
end
