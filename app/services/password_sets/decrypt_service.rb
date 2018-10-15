module PasswordSets
  class DecryptService < BaseService
    class Input < Struct.new(:encrypted_token, :user, :ip)
      def initialize(*attributes)
        super
        yield self
        freeze
      end
    end

    include PasswordEncoder

    attr_reader :input

    def initialize(input)
      @input = input
    end

    def call
      @password_set = find_password_set!

      if @password_set.decrypted?
        create_password_view!(PasswordView.statuses[:viewed])
        ::Result::Failure.new(error: I18n.t('password.decrypt.already_decrypted'))
      else
        @password_set.update!(decrypted: true)
        create_password_view!(PasswordView.statuses[:decrypted])
        passwords = @password_set.passwords.map do |password|
          decrypt(password.encrypted_password)
        end
        ::Result::Success.new(passwords: passwords)
      end
    rescue ActiveRecord::RecordNotFound, ArgumentError, OpenSSL::Cipher::CipherError
      ::Result::Failure.new(error: I18n.t('password.decrypt.error'))
    end

    private

    def find_password_set!
      PasswordSet.find_by!(access_token: decrypt(input.encrypted_token))
    end

    def create_password_view!(status)
      @password_set.password_views
        .create!(status: status,
                 viewer_id: viewer_id,
                 ip: input.ip)
    end

    def viewer_id
      input.user.present? ? input.user.id : nil
    end
  end
end
