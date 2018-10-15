module Sessions
  class CheckRefreshTokenService < BaseService
    class Input < Struct.new(:refresh_token)
      def initialize(*attributes)
        super
        yield self
        freeze
      end
    end

    attr_reader :input

    def initialize(input)
      @input = input
    end

    def call
      @session =
        Session.refreshable.find_by!(refresh_token: input.refresh_token)

      ::Result::Success.new(session: @session, user: @session.user)
    rescue ActiveRecord::RecordNotFound => _e
      ::Result::Failure.new(error: I18n.t('auth.errors.refresh_token'))
    end
  end
end
