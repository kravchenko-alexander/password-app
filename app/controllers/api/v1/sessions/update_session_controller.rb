module Api
  module V1
    module Sessions
      class UpdateSessionController < SessionsController
        before_action :check_tokens!

        def update
          result = ::Sessions::UpdateService.new(session_input).call
          if result.success?
            create_response_auth_headers(result.session)

            render_success
          else
            render_error :unprocessable_entity, result.error
          end
        end

        private

        def push_token
          params[:push_token]
        end

        def session_input
          ::Sessions::UpdateService::Input.new do |input|
            input.email = @current_user.email
            input.push_token = push_token
            input.session = @current_session
          end
        end

        def check_tokens!
          if push_token.present?
            authenticate!
          else
            authenticate_refresh!
          end
        end

        def authenticate_refresh!
          result = ::Sessions::CheckRefreshTokenService.new(
            ::Sessions::CheckRefreshTokenService::Input.new do |input|
              input.refresh_token = request.headers['Refresh-Token']
            end
          ).call

          if result.success?
            @current_session = result.session
            @current_user = result.user
          else
            render_error :unauthorized, result.error
          end
        end
      end
    end
  end
end
