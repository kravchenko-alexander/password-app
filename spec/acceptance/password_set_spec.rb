require 'acceptance_helper'

resource 'Password Sets', acceptance: true do
  include PasswordEncoder

  describe '#create' do
    post 'api/v1/password_sets' do
      let(:session) { create(:session) }
      let(:user) { session.user }

      before do
        header 'Access-Token', session.access_token
      end

      parameter :password, 'Password or list of passwords'

      context 'single password' do
        let!(:password) { SecureRandom.hex }

        example 'Create password link for single password' do
          do_request(format: :json)
          expect(status).to eq(200)

          expect(json['link']).not_to be_nil
        end
      end

      context 'list of passwords' do
        let!(:password) { [SecureRandom.hex,
                           SecureRandom.hex,
                           SecureRandom.hex] }

        example 'Create password link for list of passwords' do
          do_request(format: :json)
          expect(status).to eq(200)

          expect(json['link']).to eq("#{ENV['HOST_FOR_PASSWORD_SET']}/api/v1/password_sets/#{CGI.escape(encrypt(user.password_sets.last.access_token))}")
        end
      end

      example 'Create [UNAUTHORIZED (invalid Access-Token)]' do
        header 'Access-Token', ''
        do_request(format: :json)
        expect(status).to eq(401)
      end

      example 'Create [UNAUTHORIZED (Expired Access-Token)]' do
        session.update(access_token_expired_at: Time.current - 1.day)
        do_request(format: :json)
        expect(status).to eq(401)
      end
    end
  end

  describe '#show' do
    get 'api/v1/password_sets/:encrypted_token' do
      parameter :encrypted_token, 'Password set link', required: true

      context 'by guest' do
        let!(:user) { create(:user) }

        context 'single password' do
          let!(:password_set) { create(:password_set, :with_password, user: user) }
          let!(:encrypted_token) { encrypt(password_set.access_token) }

          example 'Get decrypted password set for single password' do
            do_request(format: :json)
            expect(status).to eq(200)

            expect(json['password']).to eq('password')

            password_set.reload

            expect(password_set.password_views.last.status).to eq('decrypted')
            expect(password_set.decrypted?).to eq(true)
          end
        end

        context 'list of passwords' do
          let!(:password_set) { create(:password_set, :with_passwords, user: user) }
          let!(:encrypted_token) { encrypt(password_set.access_token) }

          example 'Get decrypted list for list of passwords' do
            do_request(format: :json)
            expect(status).to eq(200)

            expect(json['password_set'].count).to eq(3)
            expect(json['password_set'].first['password']).to eq('password')

            password_set.reload

            expect(password_set.password_views.last.status).to eq('decrypted')
            expect(password_set.decrypted?).to eq(true)
          end

          example 'Get decrypted password from already decrypted set [FORBIDDEN]' do
            password_set.update(decrypted: true)
            do_request(format: :json)
            expect(status).to eq(403)
            expect(password_set.password_views.last.status).to eq('viewed')
          end
        end

        example 'Get decrypted password set [FORBIDDEN]' do
          do_request(encrypted_token: '1', format: :json)
          expect(status).to eq(403)
        end
      end

      context 'by user' do
        let!(:session) { create(:session) }
        let!(:user) { session.user }
        let!(:password_set_user) { create(:user) }

        before do
          header 'Access-Token', session.access_token
        end

        context 'single password' do
          let!(:password_set) { create(:password_set, :with_password, user: password_set_user) }
          let!(:encrypted_token) { encrypt(password_set.access_token) }

          example 'Get decrypted password set for single password by user ' do
            do_request(format: :json)
            expect(status).to eq(200)

            expect(json['password']).to eq('password')

            password_set.reload

            expect(password_set.password_views.last.status).to eq('decrypted')
            expect(password_set.password_views.last.viewer_id).to eq(user.id)
            expect(password_set.decrypted?).to eq(true)
          end
        end

        context 'list of passwords' do
          let!(:password_set) { create(:password_set, :with_passwords, user: password_set_user) }
          let!(:encrypted_token) { encrypt(password_set.access_token) }

          example 'Get decrypted list for list of passwords by user' do
            do_request(format: :json)
            expect(status).to eq(200)

            expect(json['password_set'].count).to eq(3)
            expect(json['password_set'].first['password']).to eq('password')

            password_set.reload

            expect(password_set.password_views.last.status).to eq('decrypted')
            expect(password_set.password_views.last.viewer_id).to eq(user.id)
            expect(password_set.decrypted?).to eq(true)
          end

          example 'Get decrypted password from already decrypted set by user [FORBIDDEN]' do
            password_set.update(decrypted: true)
            do_request(format: :json)
            expect(status).to eq(403)
            expect(password_set.password_views.last.status).to eq('viewed')
          end
        end

        example 'Get decrypted password set, invalid link [FORBIDDEN]' do
          do_request(encrypted_token: '1', format: :json)
          expect(status).to eq(403)
        end

        example 'Get decrypted password set, invalid Access-Token [UNAUTHORIZED]' do
          header 'Access-Token', '21'
          do_request(format: :json)
          expect(status).to eq(401)
        end
      end
    end
  end
end
