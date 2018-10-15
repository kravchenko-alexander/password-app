require 'acceptance_helper'

resource 'Password Views', acceptance: true do
  include PasswordEncoder

  describe '#index' do
    get 'api/v1/password_views/:encrypted_token' do
      let(:session) { create(:session) }
      let(:user) { session.user }
      let!(:password_set) { create(:password_set, :with_views, user: user) }
      let!(:encrypted_token) { encrypt(password_set.access_token) }
      let!(:page) { 1 }

      before do
        header 'Access-Token', session.access_token
      end

      parameter :encrypted_token, 'Password set link', required: true
      parameter :page, 'Pagination, default 1', required: false

      example 'Get list' do
        do_request(format: :json)
        expect(status).to eq(200)

        expect(json['current_page']).to eq(1)
        expect(json['password_views'].count).to eq(3)
      end

      example 'Get list [UNAUTHORIZED (Access-Token is wrong)]' do
        header 'Access-Token', ''
        do_request(format: :json)
        expect(status).to eq(401)
      end

      example 'Get list [UNAUTHORIZED (Access-Token is expired)]' do
        session.update(access_token_expired_at: Time.current - 1.day)
        do_request(format: :json)
        expect(status).to eq(401)
      end
    end
  end
end
