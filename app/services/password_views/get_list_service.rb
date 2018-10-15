module PasswordViews
  class GetListService < BaseService
    class Input < Struct.new(:encrypted_token, :user, :page)
      def initialize(*attributes)
        super
        yield self
        freeze
      end
    end

    class AuthorizedError < StandardError; end

    include PasswordEncoder

    attr_reader :input

    def initialize(input)
      @input = input
    end

    def call
      @password_set = find_password_set!

      raise AuthorizedError.new unless @password_set.user_id == input.user.id

      ::Result::Success.new(password_views: @password_set.password_views.page(input.page))
    rescue ActiveRecord::RecordNotFound, ArgumentError, OpenSSL::Cipher::CipherError
      ::Result::Failure.new(error: I18n.t('password.decrypt.error'))
    rescue AuthorizedError
      ::Result::Failure.new(error: I18n.t('auth.errors.unauthorized'))
    end

    private

    def find_password_set!
      PasswordSet.find_by!(access_token: decrypt(input.encrypted_token))
    end
  end
end
