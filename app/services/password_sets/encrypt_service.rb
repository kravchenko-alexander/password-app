module PasswordSets
  class EncryptService < BaseService
    class Input < Struct.new(:user, :passwords)
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
        @password_set = input.user.password_sets.create!(password_set_attrs)

        input.passwords.each do |password|
          @password_set.passwords.create!(encrypted_password: encrypt(password))
        end
      end

      ::Result::Success.new(password_set_link: password_set_link)
    rescue ActiveRecord::RecordInvalid => e
      ::Result::Failure.new(error: e.message)
    end

    private

    def password_set_attrs
      { access_token: get_token(input.user.email) }
    end

    def password_set_link
      "#{env_host}/api/v1/password_sets/#{password_set_access_token}"
    end

    def password_set_access_token
      CGI.escape(encrypt(@password_set.access_token))
    end

    def env_host
      ENV['HOST_FOR_PASSWORD_SET'] || 'http://localhost:8080'
    end
  end
end
