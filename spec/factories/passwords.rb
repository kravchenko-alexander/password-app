require 'faker'
include PasswordEncoder

FactoryBot.define do
  factory :password, class: Password do
    encrypted_password { encrypt('password') }
    password_set
  end
end
