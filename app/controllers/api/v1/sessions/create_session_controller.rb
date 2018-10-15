module Api
  module V1
    module Sessions
      class CreateSessionController < SessionsController
        def create
          result = ::Sessions::CreateService.new(session_input).call
          if result.success?
            create_response_auth_headers(result.session)

            render 'api/v1/users/show',
                   locals: { user: result.user },
                   status: :ok
          else
            render_error :unprocessable_entity, result.error
          end
        end

        private

        def user_params
          @user_params ||= params.require(:user).permit(:email,
                                                        :password)
        end

        def session_params
          @session_params ||= params.require(:session).permit(:push_token,
                                                              :device)
        end

        def session_input
          ::Sessions::CreateService::Input.new do |input|
            input.email = user_params[:email]
            input.password = user_params[:password]
            input.push_token = session_params[:push_token]
            input.device = session_params[:device]
          end
        end
      end
    end
  end
end
