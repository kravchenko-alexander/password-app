require 'acceptance_helper'

resource 'Sessions', acceptance: true do
  describe '#create' do
    post 'api/v1/sessions' do
      let(:session) { create(:session) }
      let(:user) { session.user }

      let!(:user_email) { user.email }
      let!(:user_password) { 'L0ve4ever!' }
      let!(:session_device) { session.device }
      let!(:session_push_token) { session.push_token }

      with_options scope: :user, required: true do
        parameter :email, 'User email'
        parameter :password, 'User password'
      end

      with_options scope: :session do
        parameter :device, 'Device type', required: true
        parameter :push_token, 'Push token for platform notifications', required: false
      end

      example 'Login' do
        do_request(format: :json)
        expect(status).to eq(200)

        session = Session.find_by(access_token: response_headers['Access-Token'],
                                  refresh_token: response_headers['Refresh-Token'])
        expect(user).to eq(session.user)

        expect(json['id']).to eq(user.id)
        expect(json['email']).to eq(user.email)
      end

      example 'Login with invalid password [UNPROCESSABLE ENTITY]' do
        do_request(user: { password: '1234' }, format: :json)
        expect(status).to eq(422)
      end

      example 'Login in with invalid email [UNPROCESSABLE ENTITY]' do
        do_request(user: { email: '1234' }, format: :json)
        expect(status).to eq(422)
      end
    end
  end

  describe '#delete' do
    let(:session) { create(:session) }
    let(:user) { session.user }

    before do
      header 'Access-Token', session.access_token
    end

    delete 'api/v1/sessions' do
      example 'Sign out' do
        do_request(format: :json)
        expect(status).to eq(200)
      end

      example 'Sign out [UNAUTHORIZED (Access-Token is wrong)]' do
        header 'Access-Token', ''
        do_request(format: :json)
        expect(status).to eq(401)
      end

      example 'Sign out [UNAUTHORIZED (Expired Access-Token)]' do
        session.update(access_token_expired_at: Time.current - 1.day)
        do_request(format: :json)
        expect(status).to eq(401)
      end
    end
  end

  describe '#update' do
    context 'update push token' do
      let(:session) { create(:session) }
      let(:user) { session.user }
      let!(:push_token) { SecureRandom.hex }

      before do
        header 'Access-Token', session.access_token
      end

      put 'api/v1/sessions' do
        parameter :push_token, 'Push token for platform notifications', required: false

        example 'Update push token' do
          do_request(format: :json)

          expect(status).to eq(200)

          response_session = Session.find_by(access_token: response_headers['Access-Token'],
                                             refresh_token: response_headers['Refresh-Token'])
          expect(session.id).to eq(response_session.id)
          expect(response_session.push_token).to eq(push_token)
        end

        example 'Update push token [UNAUTHORIZED (Access-Token is wrong)]' do
          header 'Access-Token', ''
          do_request(format: :json)
          expect(status).to eq(401)
        end

        example 'Update push token [UNAUTHORIZED (Access-Token is expired)]' do
          session.update(access_token_expired_at: Time.current - 1.day)
          do_request(format: :json)
          expect(status).to eq(401)
        end
      end
    end

    context 'update access token by refresh token' do
      let(:session) { create(:session, :non_active) }
      let(:user) { session.user }

      before do
        header 'Refresh-Token', session.refresh_token
      end

      put 'api/v1/sessions' do
        example 'Update access token and refresh token' do
          do_request(format: :json)

          expect(status).to eq(200)

          response_session = Session.find_by(access_token: response_headers['Access-Token'],
                                             refresh_token: response_headers['Refresh-Token'])
          expect(session.id).to eq(response_session.id)
        end

        example 'Update access token [UNAUTHORIZED (Access-Token is wrong)]' do
          header 'Refresh-Token', ''
          do_request(format: :json)
          expect(status).to eq(401)
        end

        example 'Update access token [UNAUTHORIZED (Access-Token is expired)]' do
          session.update(refresh_token_expired_at: Time.current - 1.day)
          do_request(format: :json)
          expect(status).to eq(401)
        end
      end
    end
  end
end
