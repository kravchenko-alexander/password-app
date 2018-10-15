require 'faker'

FactoryBot.define do
  factory :password_view, class: PasswordView do
    status { 'viewed' }
    viewer_id { create(:user).id }
    password_set
  end
end
