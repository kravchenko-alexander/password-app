require 'acceptance_helper'

resource 'Registration', acceptance: true do
  describe '#create' do
    post 'api/v1/registrations' do
      let!(:user_email) { Faker::Internet.email }
      let!(:user_password) { 'L0ve4ever!' }
      let!(:user_password_confirmation) { 'L0ve4ever!' }
      let!(:session_device) { 'ios' }
      let!(:session_push_token) { SecureRandom.hex }

      with_options scope: :user, required: true do
        parameter :email, 'Users email, format: ([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})'
        parameter :password, 'Users password, length: min - 6, max - 32'
        parameter :password_confirmation, 'Users password confirmation, should be equal to password'
      end

      with_options scope: :session do
        parameter :device, 'Device type, allowed values: [web, ios, android]', required: true
        parameter :push_token, 'Push token, unique field in database, used for push notifications', required: false
      end

      example 'Create new user' do
        do_request(format: :json)
        expect(status).to eq(200)

        new_user = User.find_by(email: user_email)
        session = Session.find_by(access_token: response_headers['Access-Token'],
                                  refresh_token: response_headers['Refresh-Token'])
        expect(new_user).to eq(session.user)

        expect(json['id']).to eq(new_user.id)
        expect(json['email']).to eq(new_user.email)
      end

      example 'Create new user invalid [INVALID]' do
        do_request(user: { email: nil }, format: :json)

        expect(status).to eq(422)
      end
    end
  end

  describe '#update' do
    put 'api/v1/registrations' do
      let!(:session) { create(:session) }
      let!(:user) { session.user }
      let!(:user_current_password) { 'L0ve4ever!' }
      let!(:user_password) { 'L0ve4ever!L0ve4ever!' }
      let!(:user_password_confirmation) { 'L0ve4ever!L0ve4ever!' }

      with_options scope: :user, required: true do
        parameter :current_password, 'User current password'
        parameter :password, 'User password, length: min - 6, max - 32'
        parameter :password_confirmation, 'User password confirmation, should be equal to password'
      end

      before do
        header 'Access-Token', session.access_token
      end

      example 'Update user password' do
        do_request(format: :json)
        expect(status).to eq(200)

        user.reload
        expect(user.authenticate(user_password)).not_to be_nil
      end

      example 'Update user password [UNPROCESSABLE ENTITY]' do
        do_request(user: { password_confirmation: nil }, format: :json)

        expect(status).to eq(422)
      end

      example 'Update user password [UNAUTHORIZED]' do
        header 'Access-Token', ''
        do_request(format: :json)

        expect(status).to eq(401)
      end
    end
  end
end
