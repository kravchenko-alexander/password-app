module Api
  module V1
    module PasswordSets
      class ShowPasswordSetController < PasswordSetsController
        before_action :check_token

        def show
          result = ::PasswordSets::DecryptService.new(password_input).call
          if result.success?
            render 'api/v1/password_sets/decrypted',
                   locals: { passwords: result.passwords },
                   status: :ok
          else
            render_error :forbidden, result.error
          end
        end

        private

        def password_params
          params.require(:encrypted_token)
        end

        def password_input
          ::PasswordSets::DecryptService::Input.new do |input|
            input.encrypted_token = password_params
            input.user = @current_user
            input.ip = request.remote_ip
          end
        end

        def check_token
          authenticate! if request.headers['Access-Token'].present?
        end
      end
    end
  end
end
