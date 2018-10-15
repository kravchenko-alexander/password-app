require 'faker'

FactoryBot.define do
  factory :user, class: User do
    email { Faker::Internet.email }
    password 'L0ve4ever!'
    password_confirmation 'L0ve4ever!'
  end
end
