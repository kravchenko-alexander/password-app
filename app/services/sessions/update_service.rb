module Sessions
  class UpdateService < BaseService
    class Input < Struct.new(:session, :push_token, :email)
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
      if input.push_token.present?
        input.session.update!(push_token: input.push_token)
      else
        input.session.update!(session_attrs)
      end

      ::Result::Success.new(session: input.session)
    rescue ActiveRecord::RecordInvalid => e
      ::Result::Failure.new(error: e.message)
    rescue ArgumentError => e
      ::Result::Failure.new(error: e.message)
    end

    private

    def session_attrs
      {
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
