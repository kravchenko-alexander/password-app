module Registrations
  class CreateService < BaseService
    class Input < Struct.new(:email, :password, :password_confirmation, :push_token, :device)
      def initialize(*attributes)
        super
        yield self
        freeze
      end
    end

    include GenerateToken

    attr_reader :input

    def initialize(input)
      @input = input
    end

    def call
      ActiveRecord::Base.transaction do
        @user = User.create!(user_attributes)
        @session = @user.sessions.create!(session_attributes)
      end

      ::Result::Success.new(user: @user, session: @session)
    rescue ActiveRecord::RecordInvalid => e
      ::Result::Failure.new(error: e.message)
    rescue ArgumentError => e
      ::Result::Failure.new(error: e.message)
    end

    private

    def user_attributes
      {
        email: input.email,
        password: input.password,
        password_confirmation: input.password_confirmation
      }
    end

    def session_attributes
      {
        push_token: input.push_token,
        device: input.device,
        access_token: access_token,
        access_token_expired_at: access_token_expired_at,
        refresh_token_expired_at: refresh_token_expired_at,
        refresh_token: refresh_token
      }
    end

    def access_token
      get_token(input.email)
    end

    def access_token_expired_at
      Time.current + access_token_expiration_in_seconds
    end

    def access_token_expiration_in_seconds
      (ENV['ACCESS_TOKEN_EXPIRATION_SECONDS'] || 3600).to_i
    end

    def refresh_token
      get_token(input.email)
    end

    def refresh_token_expired_at
      Time.current + refresh_token_expiration_in_seconds
    end

    def refresh_token_expiration_in_seconds
      (ENV['REFRESH_TOKEN_EXPIRATION_SECONDS'] || 3600 * 24 * 365).to_i
    end
  end
end
