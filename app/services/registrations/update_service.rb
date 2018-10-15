module Registrations
  class UpdateService < BaseService
    class InvalidCurrentPassword < StandardError; end
    class Input < Struct.new(:user, :current_password, :password, :password_confirmation)
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
      if input.user.authenticate(input.current_password)
        input.user.update!(password: input.password,
                           password_confirmation: input.password_confirmation)
      else
        raise InvalidCurrentPassword
      end

      ::Result::Success.new
    rescue ActiveRecord::RecordInvalid => e
      ::Result::Failure.new(error: e.message)
    rescue InvalidCurrentPassword
      ::Result::Failure.new(error: I18n.t('auth.errors.current_password'))
    end
  end
end
