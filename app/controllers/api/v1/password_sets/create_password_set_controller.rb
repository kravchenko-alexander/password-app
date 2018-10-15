module Api
  module V1
    module PasswordSets
      class CreatePasswordSetController < PasswordSetsController
        before_action :authenticate!

        def create
          result = ::PasswordSets::EncryptService.new(password_input).call
          if result.success?
            render 'api/v1/password_sets/show',
                   locals: { password_set_link: result.password_set_link },
                   status: :ok
          else
            render_error :unprocessable_entity, result.error
          end
        end

        private

        def password_params
          res = params.require(:password)
          return res.map(&:to_s) if res.is_a?(Array)
          [res.to_s]
        end

        def password_input
          ::PasswordSets::EncryptService::Input.new do |input|
            input.user = @current_user
            input.passwords = password_params
          end
        end
      end
    end
  end
end
