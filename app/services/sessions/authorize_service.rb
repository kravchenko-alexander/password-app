module Sessions
  class AuthorizeService < BaseService
    class Input < Struct.new(:access_token)
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
      @session = Session.active.find_by!(access_token: input.access_token)

      ::Result::Success.new(session: @session, user: @session.user)
    rescue ActiveRecord::RecordNotFound => _e
      ::Result::Failure.new(error: I18n.t('auth.errors.authenticaion'))
    end
  end
end
